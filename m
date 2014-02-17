From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast address
Date: Mon, 17 Feb 2014 20:25:15 +0100
Message-ID: <20140217192515.GG22833@order.stressinduktion.org>
References: <20140217.001545.981758741332832466.davem@davemloft.net> <20140217093231.GA4609@cpaasch-mac> <CAMrnHh5osKyOpmObYmWNswZuxYAc0SYUrmfohkg2GaafKmPK0w@mail.gmail.com> <20140217.141949.1387848185062797150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: kuznet@ms2.inr.ac.ru, christoph.paasch@uclouvain.be,
	fx.lebail@yahoo.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33282 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbaBQTZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:25:17 -0500
Content-Disposition: inline
In-Reply-To: <20140217.141949.1387848185062797150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 02:19:49PM -0500, David Miller wrote:
> From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Date: Mon, 17 Feb 2014 14:02:02 +0400
> 
> > Hello!
> > 
> > On Mon, Feb 17, 2014 at 1:32 PM, Christoph Paasch
> > <christoph.paasch@uclouvain.be> wrote:
> >> I don't have strong opinions for or against this patch.
> >>
> >> I was only involved in the original thread because F-X claimed that
> >> draft-iab-anycast-arch-implications (now RFC 7094) allows the use of anycast
> >> addresses for TCP, which is not what RFC 7094 is saying. There is no
> >> recommendation concerning TCP in the RFC and the situation is rather unclear.
> > 
> > The same is here.
> > 
> > Using anycast as source or bind address, why not?
> > 
> > Use of anycast with TCP? Logically impossible, ergo prohibited.
> > If someone wants to play with fire, the option can be left hidden behind
> > a sysctl disabled by default.
> 
> Agreed.

If a knob seems necessary I would vote for per address flags on those
anycast addresses (via setsockopt and netlink) so an application can
decide itself if it wants to do so.

Greetings,

  Hannes
