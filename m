From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH] Fix double dereference
Date: Fri, 07 Jan 2005 18:30:39 +0900 (JST)
Message-ID: <20050107.183039.59264047.yoshfuji@linux-ipv6.org>
References: <41DA3A60.8050102@pobox.com>
	<20050107.111806.27181187.yoshfuji@linux-ipv6.org>
	<20050106195333.2a90f6cb.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, herbert@gondor.apana.org.au,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050106195333.2a90f6cb.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050106195333.2a90f6cb.davem@davemloft.net> (at Thu, 6 Jan 2005 19:53:33 -0800), "David S. Miller" <davem@davemloft.net> says:

> On Fri, 07 Jan 2005 11:18:06 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > Am I miss something?
> 
> Does every path which destroys an ipv6 socket do the
> sk_dst_reset()?  If so, your patch should be valid.

Currently, inet6_destroy_sock() in net/ipv6/af_inet6.c, which is
called from udpv6_destory_sock() etc., takes care of this.
In that means, yes.

However, one for ipv4 doesn't do this.

I'll come up with new changesets.

Thanks.

--yoshfuji
