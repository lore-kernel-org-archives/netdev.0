From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] drivers/net: Call netif_carrier_off at the end of the
 probe
Date: Thu, 17 Feb 2011 09:24:20 +0100
Message-ID: <1297931060.9613.2.camel@ceranb.intra.cera.cz>
References: <483985247.35721.1297792863958.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab1BQIYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 03:24:42 -0500
In-Reply-To: <483985247.35721.1297792863958.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-15 at 13:01 -0500, Ivan Vecera wrote:
> ----- Original Message -----
> > On Tue, 2011-02-15 at 16:22 +0100, Francois Romieu wrote:
> > > Stated this way it sounds like a core dev layer issue.
> > 
> > ...
> > > I am not completely sure after reading some history. Namely:
> > > - (37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71 ?)
> > > - c276e098d3ee33059b4a1c747354226cec58487c
> > > - 22604c866889c4b2e12b73cbf1683bda1b72a313
> > > - b47300168e770b60ab96c8924854c3b0eb4260eb
> > >
> > > I am confused.
> > 
> > Drivers that can report carrier state should do so initially some time
> > between registering a device and bringing it up (either in the bus
> > probe
> > function or the ndo_open function). It generally seems to be safe to
> > assume that the link is down initially, and then to rely on
> > notifications from the hardware. However, that does depend on the
> > behaviour of the hardware.
> > 
> Yes,that's true... forcedeth and r8169 are the drivers that detect link
> state when device is opened and call netif_carrier_on(off) appropriately.
> 
> Ivan
Dave, Francois, is it acceptable?

Ivan

