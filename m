From: Pavel Krauz <krauz@cncz.cz>
Subject: Re: capturing vlan on 2.6.18
Date: Tue, 4 Mar 2008 13:09:11 +0100
Message-ID: <200803041309.12448.krauz@cncz.cz>
References: <200802281226.08987.krauz@cncz.cz> <20080304111832.GA20494@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pekka Pietikainen <pp@ee.oulu.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kwall.cncz.cz ([194.213.192.9]:41279 "EHLO kwall.cncz.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbYCDMJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 07:09:22 -0500
In-Reply-To: <20080304111832.GA20494@ee.oulu.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tuesday 04 March 2008 12:18, Pekka Pietikainen wrote:
> On Thu, Feb 28, 2008 at 12:26:08PM +0100, Pavel Krauz wrote:
> > >> Is this a kernel bug or am I supposed to set something?
> > > It's an unfortunate side effect of hardware VLAN acceleration. It
> > > can't be turned off (apart from patching the driver to not advertise
> > > VLAN acceleration support).
> > I think that enabling VLAN tags shall be at least kernel run-time or boot time
> >  configurable option.
> Oh, the no VLAN tags with bnx2 is a slightly different matter,
> I've used the patch
> 
> #ifdef BCM_VLAN
>         if (!bp->vlgrp && !(bp->flags & ASF_ENABLE_FLAG))
>                 rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
> #else

Thanks,
I have found out that by disabling the ASF/management firmware through Broadcom 
diagnostic utility I get VLAN tags in the packets. I think that it shall be at least documented
in the driver/help. I have no idea for what the ASF is used for in linux.
There shall be a tool or option how to disable it from user space or at boot time or in driver.

Pavel


