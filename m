From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [Bridge] VLANs and bridge
Date: Wed, 26 Aug 2009 08:56:49 +0200
Message-ID: <OF89F33C42.59FE9B41-ONC125761E.002582F4-C125761E.0026292A@transmode.se>
References: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se> <4A9001E3.6060506@superduper.net> <OF2C06F138.1BC279AE-ONC125761A.0054117B-C125761A.0055C6F1@LocalDomain> <OF9BD07CB5.A2197AEA-ONC125761A.005AE004-C125761A.005B662E@transmode.se> <4A9026EA.9020404@superduper.net> <OF7400A5E8.F4AC001F-ONC125761C.00674A25-C125761C.00679758@transmode.se> <4A93EE8C.6040008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Simon Barber <simon@superduper.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:60262 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932163AbZHZHAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 03:00:54 -0400
In-Reply-To: <4A93EE8C.6040008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote on 25/08/2009 16:00:44:
>
> Joakim Tjernlund wrote:
> > Simon Barber <simon@superduper.net> wrote on 22/08/2009 19:12:10:
> >> Looking through B.1.3 it looks like the patch would need some
> >> enhancement. It provides a good basis - handling tagging/untagging and
> >> filtering, but would need a way to specify the untagged vlan separately
> >> for in and out.
> >
> > I see. Perhaps the VLAN maintainer(CC:ed) can comment too. Especially about extending
> > the VLAN code to allowed several VLANs in one interface?
>
> Just accepting additional VIDs on one VLAN device should be
> a relatively trivial change, all you need to do is call
> vlan_group_set_device() with the additional VIDs.
>
> I'd suggest to add something similar to the QoS-mapping lists
> in vlan_netlink.c for the additional VIDs.

Yes, this seems to be the easy part. There are a few bride issues though:
How would the bridge be able to filter pks based on VID?
How to control which VID to use at pkg TX?
Can you have the same VID on multiple VLAN interfaces?

     Jocke

