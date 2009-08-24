From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [Bridge] VLANs and bridge
Date: Mon, 24 Aug 2009 20:51:29 +0200
Message-ID: <OF7400A5E8.F4AC001F-ONC125761C.00674A25-C125761C.00679758@transmode.se>
References: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se> <4A9001E3.6060506@superduper.net> <OF2C06F138.1BC279AE-ONC125761A.0054117B-C125761A.0055C6F1@LocalDomain> <OF9BD07CB5.A2197AEA-ONC125761A.005AE004-C125761A.005B662E@transmode.se> <4A9026EA.9020404@superduper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net
To: Simon Barber <simon@superduper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:37733 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753235AbZHXSze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 14:55:34 -0400
In-Reply-To: <4A9026EA.9020404@superduper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Barber <simon@superduper.net> wrote on 22/08/2009 19:12:10:
>
> Looking through B.1.3 it looks like the patch would need some
> enhancement. It provides a good basis - handling tagging/untagging and
> filtering, but would need a way to specify the untagged vlan separately
> for in and out.

I see. Perhaps the VLAN maintainer(CC:ed) can comment too. Especially about extending
the VLAN code to allowed several VLANs in one interface?

>
> Simon
>
>
> Joakim Tjernlund wrote:
> > Joakim Tjernlund/Transmode wrote on 22/08/2009 17:36:54:
> >
> >> Simon Barber <simon@superduper.net> wrote on 22/08/2009 16:34:11:
> >>
> >>> Hi Joakim,
> >>>
> >>> Look back a month or so in the archives - you'll find an email from me
> >>> referencing a patch to make the bridge VLAN aware. It's a little old,
> >>> and needs updating for 2.6 (it was written for 2.4) - but should not be
> >>> much work to get it done. There is a matching patch for the brctl utility.
> >>>
> >>> Simon
> >>>
> >>>
> >> Thanks Simon
> >>
> >> Do you mean the "bridge vlan integration" patch?
> >> It is not clear to me if this would support the case
> >> described in B.1.3(802.1Q-2005), does it?
> >>
> >> Seems like there is little interest to post this to 2.6 and
> >> I am not sure how welcome this would be either, perhaps
> >> the bridge maintainer could comment?
> >>
> >>   Jocke
> >>
> >
> > Thinking a bit more about this I could envision some changes to the
> > vlan code too. I image one could create one vlan interface which will listen
> > to several VLANs. One VLAN is the primary VLAN and is used in the tx path
> > by default. The bridge would be able to filter on individual VLANs received
> > from such interface and be able to chose outgoing VLAN too.
> >
> >  Jocke
> >
> >
>
>
>

