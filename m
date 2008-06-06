From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: [PATCH] forcedeth: msi interrupts
Date: Fri, 6 Jun 2008 14:40:16 -0700
Message-ID: <20080606214016.GA3345@synapse.neuralscape.com>
References: <20080606141054.432ec910.akpm@linux-foundation.org> <F72FA20C31DD4F4C997B91C5B3690A090B146100@hqemmail07.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	manfred@colorfullife.com, netdev@vger.kernel.org
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from synapse.neuralscape.com ([198.144.200.82]:35709 "EHLO
	neuralscape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757858AbYFFVk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 17:40:26 -0400
Content-Disposition: inline
In-Reply-To: <F72FA20C31DD4F4C997B91C5B3690A090B146100@hqemmail07.nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 06, 2008 at 02:19:31PM -0700, Ayaz Abdulla wrote:
> Yes, that would be great!

Hi Ayaz,
How far back should it be back ported? Do you know?
Thanks,
Karen

> 
> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org] 
> Sent: Friday, June 06, 2008 2:11 PM
> To: Ayaz Abdulla
> Cc: jgarzik@pobox.com; manfred@colorfullife.com; netdev@vger.kernel.org
> Subject: Re: [PATCH] forcedeth: msi interrupts
> 
> 
> On Fri, 06 Jun 2008 14:04:05 -0400
> Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> 
> > 
> > 
> > Andrew Morton wrote:
> > > On Fri, 06 Jun 2008 13:15:32 -0400
> > > Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > > 
> > > 
> > >>Andrew Morton wrote:
> > >>
> > >>>On Tue, 03 Jun 2008 16:51:46 -0400
> > >>>Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > >>>
> > >>> > This patch adds a workaround for lost MSI interrupts. There is a
> race
> > >>> > condition in the HW in which future interrupts could be missed.
> The
> > >>> > workaround is to toggle the MSI irq mask.
> > >>> >
> > >>>
> > >>>Do you think this is a 2.6.26 thing?
> > >>
> > >>It is by HW design, not related to the kernel.
> > > 
> > > 
> > > Sorry, what I meant was: do you believe that this patch should be in
> > > 2.6.26?
> > Yes, it should be treated as a critical fix.
> 
> So should it also be backported into 2.6.25.x?
> 
> Bear in mind that $major_distros are apparently basing product on
> 2.6.25.
> -----------------------------------------------------------------------------------
> This email message is for the sole use of the intended recipient(s) and may contain
> confidential information.  Any unauthorized review, use, disclosure or distribution
> is prohibited.  If you are not the intended recipient, please contact the sender by
> reply email and destroy all copies of the original message.
> -----------------------------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---

-- 
 Karen Shaeffer
 Neuralscape, Palo Alto, Ca. 94306
 shaeffer@neuralscape.com  http://www.neuralscape.com
