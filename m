From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/4] e1000e: Fix jumbo frame receive code.
Date: Thu, 25 Oct 2007 14:05:41 -0700
Message-ID: <47210525.4020606@intel.com>
References: <20071025205744.32645.59503.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16267 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275AbXJYVJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 17:09:17 -0400
In-Reply-To: <20071025205744.32645.59503.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Fix allocation and freeing of jumbo frames where several bugs
> were recently introduced by cleanups after we forked this code
> from e1000. This moves ps_pages to buffer_info where it really
> belongs and makes it a dynamically allocated array. The penalty
> is not that high since it's allocated outside of the buffer_info
> struct anyway.
> 
> Without this patch all jumbo frames are completely broken and the
> driver panics.


Jeff,

I strongly suggest that you apply patches #1 and #2 (but preferably all) to
#upstream-fixes since these patches fix the -absolutely- broken jumbo frames code
in e1000e. On top of that patches #1 and #2 only touch the jumbo frame codepath,
so the impact is zero to the normal way people use these cards.

patch #3 is an optimization, patch #4 is mostly cosmetical.

Cheers,

Auke
