From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Wed, 8 Jan 2014 00:17:46 -0800 (PST)
Message-ID: <1389169066.26962.YahooMailBasic@web125506.mail.ne1.yahoo.com>
References: <20140107205101.GJ30393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm32.bullet.mail.ne1.yahoo.com ([98.138.229.25]:38568 "HELO
	nm32.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754987AbaAHIUp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 03:20:45 -0500
In-Reply-To: <20140107205101.GJ30393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1/7/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

> On Tue, Jan 07, 2014 at 02:57:27PM +0100, Francois-Xavier Le Bail wro=
te:
> > --- a/include/net/netns/ipv6.h
> > +++ b/include/net/netns/ipv6.h
> > @@ -73,6 +73,7 @@ struct netns_ipv6 {
> >  #endif
> >  	atomic_t		dev_addr_genid;
> >  	atomic_t		rt_genid;
> > +	int			anycast_src_echo_reply;
> >  };

> Sorry, I missed that on first review and you could also do that as a
> follow-up:

> Could you move anycast_src_echo_reply to netns_sysctl_ipv6?

I can do that, but please explain what this change is needed.

BR
=46ran=E7ois-Xavier
