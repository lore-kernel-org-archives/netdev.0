From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] kill needless addrconf lock in sctp.
Date: Wed, 19 Jan 2005 14:37:00 -0800
Message-ID: <20050119143700.3caa0187.davem@davemloft.net>
References: <20050107.123519.125017441.yoshfuji@linux-ipv6.org>
	<20050107.124123.07582199.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: sri@us.ibm.com, lksctp-developers@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050107.124123.07582199.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 07 Jan 2005 12:41:23 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20050107.123519.125017441.yoshfuji@linux-ipv6.org> (at Fri, 07 Jan 2005 12:35:19 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > After applying this patch, I think we can stop exporting
> > addrconf_lock.
> 
> Oops, sorry, we can't, because in6_dev_get() is inlined function,
> and it uses addrconf_lock.

Right.  I think we should just leave the SCTP code as-is for
now.
