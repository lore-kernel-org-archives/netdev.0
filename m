From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC] skge: limit DMA to 32 bit
Date: Wed, 22 Sep 2010 09:34:01 +0200
Message-ID: <20100922073400.GA9942@redhat.com>
References: <20100921071518.GA9081@redhat.com>
 <20100921080253.3d89d60a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780Ab0IVHc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Sep 2010 03:32:56 -0400
Content-Disposition: inline
In-Reply-To: <20100921080253.3d89d60a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 21, 2010 at 08:02:53AM -0700, Stephen Hemminger wrote:
> > Is 32bit DMA limit for every skge device acceptable patch?
> 
> No. The device does support 64 bit DMA, the problem is a crap implementation
> of the device the motherboard. Therefore a PCI quirk or module parameter
> is a better solution.

Ok, I will use dmi_check_system() to recognize broken board and limit DMA
address space when detected.

Thanks
Stanislaw
