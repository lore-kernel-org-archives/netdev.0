From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Tue, 24 Mar 2009 14:22:09 -0700 (PDT)
Message-ID: <20090324.142209.234280606.davem@davemloft.net>
References: <OF2EE08546.DF677136-ONC1257582.0037C87E-C1257582.00388BCE@transmode.se>
	<20090323.114928.01832203.davem@davemloft.net>
	<OFA0B803BB.DEC93B9A-ONC1257583.0039CF3E-C1257583.003A55BA@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44811
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750808AbZCXVWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 17:22:21 -0400
In-Reply-To: <OFA0B803BB.DEC93B9A-ONC1257583.0039CF3E-C1257583.003A55BA@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Tue, 24 Mar 2009 11:37:11 +0100

> David Miller <davem@davemloft.net> wrote on 23/03/2009 19:49:28:
> > 
> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > Date: Mon, 23 Mar 2009 11:17:39 +0100
> > 
> > > Sorry for the WS damaged patch, but my current company mailer cannot
> > > handle inline patches. Due to this we are setting up a new mail system
> > > but it will be a few days before this is ready.
> > > Therefore I am attaching this patch as well, use that one
> > > to apply instaed of the inline variant.
> > 
> > This patch has other problems, anyways.
> > 
> > > +#if 0
> > > +/* not yet */
> > > +       .ndo_set_mac_address    = ucc_geth_set_mac_address,
> > > +       .ndo_change_mtu         = ucc_geth_change_mtu,
> > > +       .ndo_do_ioctl           = ucc_geth_do_ioctl,
> > > +#endif
> > 
> > Don't do stuff like this, please.  Even the code you are
> > copying from doesn't have the set_mac_address method
> > assignment proceted by #if 0 stuff.
> > 
> > Just get rid of all the unused stuff completely.
> 
> OK, here is a new version. The #if 0 ..#endif has been removed.

Missing ".ndo_set_mac_address = eth_set_mac_address," and
also ".ndo_change_mtu = eth_change_mtu".

Also please inline your patches so that people can quote them in
replies.

