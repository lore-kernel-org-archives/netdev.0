From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 07 Jun 2005 17:14:23 +0900 (JST)
Message-ID: <20050607.171423.106079530.yoshfuji@linux-ipv6.org>
References: <20050607.164749.62298775.yoshfuji@linux-ipv6.org>
	<OFB68D40CB.B0CAE212-ON88257019.002B61C8-88257019.002C0A18@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OFB68D40CB.B0CAE212-ON88257019.002B61C8-88257019.002C0A18@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFB68D40CB.B0CAE212-ON88257019.002B61C8-88257019.002C0A18@us.ibm.com> (at Tue, 7 Jun 2005 01:01:01 -0700), David Stevens <dlstevens@us.ibm.com> says:

> Ok, but this gets back to my point. If the program source
> doesn't have #ifdefs like you suggested (for example, if
> it was written before the new API existed), then it'll still
> have an error, but that error won't show up until the next
> time it's recompiled. So, an old binary will work fine, but
> recompiling it will get EINVAL on the setsockopt() calls.
> The old binary will work, the old source will compile, but
> the new binary will not work, and may not be found until
> much later.

It is okay, we can warn that "you use old API; please fix that!"
or something like that.
(like SO_BSDCOMPAT or, neigh.XXX.base_reachable_time sysctl.)

> I think it's better to break and fix any use of these
> right away instead of delaying the error until the next
> time some old binary is recompiled and run, don't you?

No, I don't think so.  Please do NOT break binary API in 2.6.x.
I think it is okay in 2.7, but I still think that it is 
good to use new values for new semantics.

--yoshfuji
