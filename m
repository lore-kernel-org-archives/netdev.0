From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Wed, 7 May 2014 17:54:48 -0400
Message-ID: <20140507215448.GA21071@localhost.localdomain>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
 <20140507.155613.630399521517455317.davem@davemloft.net>
 <20140507203317.GC8786@hmsreliant.think-freely.org>
 <20140507.164434.997979341700998470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cooldavid@cooldavid.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48352 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbaEGVy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:54:57 -0400
Content-Disposition: inline
In-Reply-To: <20140507.164434.997979341700998470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 04:44:34PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 7 May 2014 16:33:17 -0400
> 
> > Perhaps a solution is a signalling mechanism tied to completion interrupts?
> > I.e. a mapping failure gets reported to the stack, which causes the
> > correspondnig queue to be stopped, until such time a the driver signals a safe
> > restart by the reception of a tx completion interrupt?  I'm actually tinkering
> > right now with a mechanism that provides guidance to the stack as to how many
> > dma descriptors are available in a given net_device that might come in handy
> > here
> 
> Another idea is to signal it from the IOMMU unmap itself, since that is the
> point where the resource becomes available.
> 
> Actually either approach is fine with me.
> 
I'll look into it shortly.  Thanks for the idea!
Neil
