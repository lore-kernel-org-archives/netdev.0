From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 07/16] dma-debug: add debugfs interface
Date: Sun, 11 Jan 2009 08:52:27 +0100
Message-ID: <20090111075227.GG9466@8bytes.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-8-git-send-email-joerg.roedel@amd.com> <20090110230826.GJ17917@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:41419 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbZAKHw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 02:52:29 -0500
Content-Disposition: inline
In-Reply-To: <20090110230826.GJ17917@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 12:08:26AM +0100, Ingo Molnar wrote:
> 
> * Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > +/* Global error count */
> > +static u32 error_count;
> > +
> > +/* Global error show enable*/
> > +static u32 show_all_errors __read_mostly;
> > +/* Number of errors to show */
> > +static u32 show_num_errors = 1;
> > +
> >  static u32 num_free_entries;
> >  static u32 min_free_entries;
> 
> Small detail: please use native C types for non-hardware variables - 
> 'unsigned int', 'unsigned long', etc.
> 
> u32/u64 is typically used for variables where there is a real significance 
> to the precise width of the variable: there's either a hardware or a 
> user-space ABI involved.

Hmm, these variables are exported to debugfs. Thats the reason I made
them u32.

Joerg
