From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] NET: Normalize jiffies reported to userspace, in
 neighbor management code
Date: Tue, 11 Nov 2003 21:36:03 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111.213603.27789451.yoshfuji@linux-ipv6.org>
References: <20031110230233.254061da.davem@redhat.com>
	<20031111.163128.48152698.yoshfuji@linux-ipv6.org>
	<20031111160200.72cee93a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031111160200.72cee93a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031111160200.72cee93a.davem@redhat.com> (at Tue, 11 Nov 2003 16:02:00 -0800), "David S. Miller" <davem@redhat.com> says:

> I'm asking Linus what we should do here.  It's a big change to
> make to fix this bug, and if he thinks so too we'll just use
> your original patch which is a safer version of the fix for 2.6.0
> purposes.  If that happens, we'll integrate this nicer version
> for 2.6.1 or something like this.

Yes, it is the reason why I did not submit this fisrt;
to avoid "big" change before 2.6.0.
Just in case Linus accept this change now, please apply following 
on top of the patch because I sent you wrong version with typo...

Thanks.

--- linux26-sysctl/kernel/sysctl.c.orig	Wed Nov 12 12:25:35 2003
+++ linux26-sysctl+fix/kernel/sysctl.c	Wed Nov 12 12:27:18 2003
@@ -1413,7 +1413,7 @@
 			if (!first)
 				*p++ = '\t';
 	
-			if (conv(&neg, &lval, i, 1, data))
+			if (conv(&neg, &lval, i, 0, data))
 				break;
 
 			sprintf(p, "%s%lu", neg ? "-" : "", lval);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
