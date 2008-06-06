From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth: msi interrupts
Date: Fri, 6 Jun 2008 13:19:28 -0700
Message-ID: <20080606131928.592fa23c.akpm@linux-foundation.org>
References: <4845AEE2.1090905@nvidia.com>
	<20080604151854.4a6f22b8.akpm@linux-foundation.org>
	<484970B4.6080500@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com,
	akpm@linuxfoundation.org, netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50748 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752218AbYFFUUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 16:20:22 -0400
In-Reply-To: <484970B4.6080500@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 06 Jun 2008 13:15:32 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> Andrew Morton wrote:
> > On Tue, 03 Jun 2008 16:51:46 -0400
> > Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > 
> >  > This patch adds a workaround for lost MSI interrupts. There is a race
> >  > condition in the HW in which future interrupts could be missed. The
> >  > workaround is to toggle the MSI irq mask.
> >  >
> > 
> > Do you think this is a 2.6.26 thing?
> It is by HW design, not related to the kernel.

Sorry, what I meant was: do you believe that this patch should be in
2.6.26?
