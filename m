From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] kill needless addrconf lock in sctp.
Date: Fri, 07 Jan 2005 12:41:23 +0900 (JST)
Message-ID: <20050107.124123.07582199.yoshfuji@linux-ipv6.org>
References: <20050107.123519.125017441.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com, davem@davemloft.net
In-Reply-To: <20050107.123519.125017441.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050107.123519.125017441.yoshfuji@linux-ipv6.org> (at Fri, 07 Jan 2005 12:35:19 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> After applying this patch, I think we can stop exporting
> addrconf_lock.

Oops, sorry, we can't, because in6_dev_get() is inlined function,
and it uses addrconf_lock.

--yoshfuji
