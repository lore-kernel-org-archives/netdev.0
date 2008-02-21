From: "Divy Le Ray" <divy@chelsio.com>
Subject: RE: [git patches] net driver updates
Date: Wed, 20 Feb 2008 21:57:08 -0800
Message-ID: <8A71B368A89016469F72CD08050AD334026D6511@maui.asicdesigners.com>
References: <47BCD0DF.1050205@chelsio.com><OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com> <20080220.214651.235108740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:16666 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbYBUF5W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 00:57:22 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 20, 2008 9:47 PM
> To: krkumar2@in.ibm.com
> Cc: Divy Le Ray; jeff@garzik.org; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: Re: [git patches] net driver updates
> 
> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Thu, 21 Feb 2008 09:13:49 +0530
> 
> > Hi Divy,
> >
> > > > Explain why, so I can include it in the changelog please...
> > >
> > > Hi Jeff,
> > >
> > > The first part of the patch removes the !netif_queue_stopped(dev).
> > > It opens the race discussed a while ago between Stephen hemminger
> and
> > > David Miller:
> > > http://marc.info/?l=linux-netdev&m=113383224512427&w=2
> >
> > I feel this race cannot happen anymore. I think the fix for that
race
> was
> > to introduce the
> > __LINK_STATE_QDISC_RUNNING bit thus eliminating any races between
> CPU's. If
> > one
> > CPU has called xmit, the other CPU will enqueue skbs (by holding the
> > queue_lock) and
> > exit from qdisc_run since it finds the bit set already.
> 
> And the race is talking about LLTX, which S2IO doesn't use as
> far as I can tell.

Dave,

The driver is cxgb3 here, it uses LLTX.

Cheers,
Divy
