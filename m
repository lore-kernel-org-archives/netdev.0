From: Matthew Garrett <mjg@redhat.com>
Subject: Re: [net-2.6 PATCH] e1000e: enable/disable ASPM L0s and L1 and ERT
	according to hardware errata
Date: Tue, 27 Apr 2010 14:43:35 +0100
Message-ID: <20100427134335.GA2218@srcf.ucam.org>
References: <20100427133232.25490.92973.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:48570 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab0D0Nnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 09:43:45 -0400
Content-Disposition: inline
In-Reply-To: <20100427133232.25490.92973.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 06:33:04AM -0700, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Prompted by a previous patch submitted by Matthew Garret <mjg@redhat.com>,
> further digging into errata documentation reveals the current enabling or
> disabling of ASPM L0s and L1 states for certain parts supported by this
> driver are incorrect.  82571 and 82572 should always disable L1.  For
> standard frames, 82573/82574/82583 can enable L1 but L0s must be disabled,
> and for jumbo frames 82573/82574 must disable L1.  This allows for some
> parts to enable L1 in certain configurations leading to better power
> savings.
> 
> Also according to the same errata, Early Receive (ERT) should be disabled
> on 82573 when using jumbo frames.

Looks good. Thanks for digging into this!

-- 
Matthew Garrett | mjg59@srcf.ucam.org
