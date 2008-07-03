From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] support for IEEE 1588
Date: Fri, 4 Jul 2008 02:40:04 +0300
Message-ID: <200807040240.04801.opurdila@ixiacom.com>
References: <200807040147.11148.opurdila@ixiacom.com> <20080703162428.55d9f345@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1454 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757716AbYGCXmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 19:42:05 -0400
In-Reply-To: <20080703162428.55d9f345@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 July 2008, Stephen Hemminger wrote:

> >
> > 1. RX path
> > - add a new field in skb to keep the hardware stamp (hwstamp)
> > - add a new socket flag to enable RX stamping
> > - add a new control message to retrieve the hwstamp from the skb to
> > user-space application (for UDP and maybe PF_PACKET)
>
> The existing skb timestamp is there, and if the hardware supports it, it
> could be updated by the device driver  I had a version of sky2 that did
> just that but never fully pushed it upstream because of available time and
> testing issues.
>
> The API's are already there (and used) for timestamping; don't invent
> new ones.

Hi Stephen,

Thanks for taking the time to respond.

The hardware we will be using will not have the timestamping unit synchronized 
to gettimeofday(). In this conditions, is it OK to put our hw stamp into 
skb->tstamp?

Also, are there any APIs we can use on the TX side as well?

Thanks,
tavi


