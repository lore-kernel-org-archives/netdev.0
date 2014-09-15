From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: curent state of GSO over IPv6 tunnel
Date: Mon, 15 Sep 2014 03:29:55 -0700
Message-ID: <1410776995.7106.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <B5657A6538887040AD3A81F1008BEC63B365F6@avmb3.qlogic.org>
	 <1410776054.7106.141.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63B366DB@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:64414 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbaIOK35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:29:57 -0400
Received: by mail-pd0-f176.google.com with SMTP id y13so5989969pdi.35
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 03:29:56 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B366DB@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-15 at 10:19 +0000, Yuval Mintz wrote:
> > > Hi,
> > >
> > > Tried running simple scenarios using ipv6/ipv6 via gre-tunnel [ip6_gre].
> > >
> > > When I've tried sniffing Tx traffic [tcpdump] I've noticed there were
> > > no aggregations being set, i.e., only MTU-sized packets reached NIC.
> > >
> > > Looking at output of `ethtool -k', I can see `tx_gre_segmentation' is on.
> > >
> > > What's the current state of the feature? Is it feasible and I'm
> > > missing some configuration, or is it yet an unsupported feature?
> > 
> > As far as I know, only bnx2x driver currently supports NETIF_F_GSO_GRE
> > 
> 
> Hi Eric,
> 
> Might be true, but should this flag hold any sway over IPv6?
> [Both at the moment and in general, i.e., if it does not would we need
> an additional feature or simply extend the functionality so that it would
> effect IPv6 as well?]

Both ipv4 and ipv6 are supported under this single flag.

Really, in 2014 all NIC supporting TSO for GRE should support IPv6 as
well.
