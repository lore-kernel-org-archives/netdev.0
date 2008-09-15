From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: Bonding and Neighbour Discovery on IPv6-only devices
Date: Mon, 15 Sep 2008 14:16:49 -0400
Message-ID: <200809151416.49447.alexandre.sidorenko@hp.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:17745 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbYIOSQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 14:16:51 -0400
In-Reply-To: <20080915180015.GB1078@havoc.gtf.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 15, 2008 02:00:15 pm Jeff Garzik wrote:
> On Mon, Sep 15, 2008 at 01:35:16PM -0400, Alex Sidorenko wrote:
> > Hello,
> >
> > I suspect that there are some problems while switching slaves manually on
> > IPv6-only bonds. I have tested that this does not work on 2.6.18 kernel
> > (RHEL5). I looked at recent sources (2.6.26) and even though there were
> > multiple changes in bonding code, I still don't see how this could work.
> >
> > Testing setup
> > -------------
> >
> > Two ethernets enslaved (eth2 and eh3), active-backup bond has IPv6-only
> > address (no IPv4)
> >
> > Everything works fine, but if we switch the slave doing
> >
> > # ifenslave -c bond0 eth3
> >
> > the incoming ping6 to this host stops for up to several minutes (waiting
> > until the switch updates its caches).
>
> We _just_ put in an IPv6 fix, FWIW...
>

Hi Jeff,

do you mean the patch for ALB/TLB bonds? I looked at it but I still don't 
understand how this helps for active-backup case.

Alex


-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
