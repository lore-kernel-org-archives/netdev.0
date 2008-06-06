From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [PATCH] forcedeth: msi interrupts
Date: Fri, 6 Jun 2008 14:19:31 -0700
Message-ID: <F72FA20C31DD4F4C997B91C5B3690A090B146100@hqemmail07.nvidia.com>
References: <20080606141054.432ec910.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <manfred@colorfullife.com>,
	<netdev@vger.kernel.org>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:12287 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbYFFVXJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 17:23:09 -0400
In-Reply-To: <20080606141054.432ec910.akpm@linux-foundation.org>
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, that would be great!

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org] 
Sent: Friday, June 06, 2008 2:11 PM
To: Ayaz Abdulla
Cc: jgarzik@pobox.com; manfred@colorfullife.com; netdev@vger.kernel.org
Subject: Re: [PATCH] forcedeth: msi interrupts


On Fri, 06 Jun 2008 14:04:05 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> 
> 
> Andrew Morton wrote:
> > On Fri, 06 Jun 2008 13:15:32 -0400
> > Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > 
> > 
> >>Andrew Morton wrote:
> >>
> >>>On Tue, 03 Jun 2008 16:51:46 -0400
> >>>Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> >>>
> >>> > This patch adds a workaround for lost MSI interrupts. There is a
race
> >>> > condition in the HW in which future interrupts could be missed.
The
> >>> > workaround is to toggle the MSI irq mask.
> >>> >
> >>>
> >>>Do you think this is a 2.6.26 thing?
> >>
> >>It is by HW design, not related to the kernel.
> > 
> > 
> > Sorry, what I meant was: do you believe that this patch should be in
> > 2.6.26?
> Yes, it should be treated as a critical fix.

So should it also be backported into 2.6.25.x?

Bear in mind that $major_distros are apparently basing product on
2.6.25.
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
