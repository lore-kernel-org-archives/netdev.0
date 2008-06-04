From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: [PATCH] forcedeth: msi interrupts
Date: Wed, 4 Jun 2008 16:00:38 -0700
Message-ID: <20080604230038.GB26514@synapse.neuralscape.com>
References: <4845AEE2.1090905@nvidia.com> <20080604151854.4a6f22b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	manfred@colorfullife.com, akpm@linuxfoundation.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.144.200.82] ([198.144.200.82]:58548 "EHLO neuralscape.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757419AbYFDXhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 19:37:32 -0400
Content-Disposition: inline
In-Reply-To: <20080604151854.4a6f22b8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 04, 2008 at 03:18:54PM -0700, Andrew Morton wrote:
> On Tue, 03 Jun 2008 16:51:46 -0400
> Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> 
> > This patch adds a workaround for lost MSI interrupts. There is a race 
> > condition in the HW in which future interrupts could be missed. The 
> > workaround is to toggle the MSI irq mask.
> > 
> 
> Do you think this is a 2.6.26 thing?

Or does it go back even further, maybe even as far as 2.6.18?
I've observed the CK48 NICs hang on 2.6.18 - 2.6.24 kernels.
Just wondering if this is relevant.

Thanks,
Karen
-- 
 Karen Shaeffer
 Neuralscape, Palo Alto, Ca. 94306
 shaeffer@neuralscape.com  http://www.neuralscape.com
