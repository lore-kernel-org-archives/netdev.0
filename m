From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Tue, 24 Mar 2009 23:45:13 +0100
Message-ID: <OF603BDF0B.B740DD77-ONC1257583.007CAD9B-C1257583.007CFD35@transmode.se>
References: <OF2EE08546.DF677136-ONC1257582.0037C87E-C1257582.00388BCE@transmode.se>	<20090323.114928.01832203.davem@davemloft.net>
	<OFA0B803BB.DEC93B9A-ONC1257583.0039CF3E-C1257583.003A55BA@transmode.se> <20090324.142209.234280606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:50422 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbZCXWpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 18:45:17 -0400
In-Reply-To: <20090324.142209.234280606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 24/03/2009 22:22:09:
> 
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Tue, 24 Mar 2009 11:37:11 +0100
> 
> > David Miller <davem@davemloft.net> wrote on 23/03/2009 19:49:28:
> > > 
> > > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > > Date: Mon, 23 Mar 2009 11:17:39 +0100
> > > 
> > > > Sorry for the WS damaged patch, but my current company mailer 
cannot
> > > > handle inline patches. Due to this we are setting up a new mail 
system
> > > > but it will be a few days before this is ready.
> > > > Therefore I am attaching this patch as well, use that one
> > > > to apply instaed of the inline variant.
> > > 
> > > This patch has other problems, anyways.
> > > 
> > > > +#if 0
> > > > +/* not yet */
> > > > +       .ndo_set_mac_address    = ucc_geth_set_mac_address,
> > > > +       .ndo_change_mtu         = ucc_geth_change_mtu,
> > > > +       .ndo_do_ioctl           = ucc_geth_do_ioctl,
> > > > +#endif
> > > 
> > > Don't do stuff like this, please.  Even the code you are
> > > copying from doesn't have the set_mac_address method
> > > assignment proceted by #if 0 stuff.
> > > 
> > > Just get rid of all the unused stuff completely.
> > 
> > OK, here is a new version. The #if 0 ..#endif has been removed.
> 
> Missing ".ndo_set_mac_address = eth_set_mac_address," and
> also ".ndo_change_mtu = eth_change_mtu".

I don't follow. Are these mandatory now? They were not in the old
impl. either.
> 
> Also please inline your patches so that people can quote them in
> replies.

I know, but my mail system is screwing up WS ATM so I can't. Working
on it though.
