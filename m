From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [Bridge] VLANs and bridge
Date: Sat, 22 Aug 2009 17:36:54 +0200
Message-ID: <OF2C06F138.1BC279AE-ONC125761A.0054117B-C125761A.0055C6F1@transmode.se>
References: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se> <4A9001E3.6060506@superduper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Simon Barber <simon@superduper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:50507 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932679AbZHVPi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Aug 2009 11:38:28 -0400
In-Reply-To: <4A9001E3.6060506@superduper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Barber <simon@superduper.net> wrote on 22/08/2009 16:34:11:
>
> Hi Joakim,
>
> Look back a month or so in the archives - you'll find an email from me
> referencing a patch to make the bridge VLAN aware. It's a little old,
> and needs updating for 2.6 (it was written for 2.4) - but should not be
> much work to get it done. There is a matching patch for the brctl utility.
>
> Simon
>

Thanks Simon

Do you mean the "bridge vlan integration" patch?
It is not clear to me if this would support the case
described in B.1.3(802.1Q-2005), does it?

Seems like there is little interest to post this to 2.6 and
I am not sure how welcome this would be either, perhaps
the bridge maintainer could comment?

  Jocke

>
> Joakim Tjernlund wrote:
> > This is probably no news to experienced bridge and VLAN users but I just learned the
> > hard way that Shared VLAN learning(SVL) isn't supported
> > by the linux bridge making it impossible to support configurations described in B.1.3
> > Basically the bride needs to be made VLAN aware and the VLAN code needs to be adopted
> > to allow this.
> >
> > I figured I should mention it in case it is just an oversight. It does not
> look like a simple
> > job though.
> >
> >  Jocke
> >
> > _______________________________________________
> > Bridge mailing list
> > Bridge@lists.linux-foundation.org
> > https://lists.linux-foundation.org/mailman/listinfo/bridge
> >
>
>
>

