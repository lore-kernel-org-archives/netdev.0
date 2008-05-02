From: Michael Brown <mbrown@fensystems.co.uk>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Fri, 2 May 2008 20:10:53 +0100 (BST)
Message-ID: <Pine.LNX.4.62.0805022004350.13626@dolphin.home>
References: <200804301925.m3UJPc72001651@hera.kernel.org>
 <20080501120858.207b6dd6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprocket.fensystems.co.uk ([212.13.204.53]:34973 "EHLO
	sprocket.fensystems.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269AbYEBTnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 15:43:16 -0400
Received: from cpc2-cmbg6-0-0-cust113.cmbg.cable.ntl.com (cpc2-cmbg6-0-0-cust113.cmbg.cable.ntl.com [81.107.32.114])
	by sprocket.fensystems.co.uk (Postfix) with ESMTP id DBC1F1E12A
	for <netdev@vger.kernel.org>; Fri,  2 May 2008 20:10:53 +0100 (BST)
In-Reply-To: <20080501120858.207b6dd6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 May 2008, Andrew Morton wrote:
> >
> > ...
> >
> > --- /dev/null
> > +++ b/drivers/net/sfc/i2c-direct.h
> 
> There is no linkage with the kernel's own i2c layer?  Should there be?

Last time I checked (i.e. when I originally wrote this bit of the code), 
the kernel's own i2c layer didn't provide any clean way for kernel code 
(rather than user code) to access i2c devices.

As originally written, there was also a link to the kernel's i2c layer so 
that the NIC's onboard i2c bus could be exposed to e.g. lm_sensors for 
temperature monitoring.  I believe that this part of the driver was 
expunged since it made the patch "too large", but I may be wrong.

Michael
