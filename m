From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] fix select() for SOCK_RAW sockets (ipv6)
Date: Wed, 08 Dec 2004 16:58:50 +0900 (JST)
Message-ID: <20041208.165850.97660819.yoshfuji@linux-ipv6.org>
References: <20041208.023530.26430801.yoshfuji@linux-ipv6.org>
	<20041207100140.781f4c00@dxpl.pdx.osdl.net>
	<20041207104815.3f7a4684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mitch@sfgoth.com, kernel@linuxace.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@davemloft.net
In-Reply-To: <20041207104815.3f7a4684.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20041207104815.3f7a4684.davem@davemloft.net> (at Tue, 7 Dec 2004 10:48:15 -0800), "David S. Miller" <davem@davemloft.net> says:

> On Tue, 7 Dec 2004 10:01:40 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > > Probably, we need to do the same for ipv6, don't we?
> > 
> > diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> > --- a/net/ipv6/af_inet6.c	2004-12-07 10:02:50 -08:00
> > +++ b/net/ipv6/af_inet6.c	2004-12-07 10:02:50 -08:00
> > @@ -513,6 +513,27 @@
> 
> We didn't do the "UDP select() fix" on ipv6 because we don't
> have the delayed checksumming optimization there.  So the
> ipv6 side really doesn't need this change.

Ok, thanks for the explanation.

--yoshfuji @ Strasbourg

