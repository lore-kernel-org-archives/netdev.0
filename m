From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 16:45:35 -0700 (PDT)
Message-ID: <20120626.164535.1370104947946690268.davem@davemloft.net>
References: <1340697286-3047-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab2FZXpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 19:45:36 -0400
In-Reply-To: <1340697286-3047-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 Jun 2012 00:54:46 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> FCoE target mode was experiencing issues due to the fact that we were
> sending up data frames that were padded to 60 bytes after the DDP logic had
> already stripped the frame down to 52 or 56 depending on the use of VLANs.
> This was resulting in the FCoE DDP logic having issues since it thought the
> frame still had data in it due to the padding.
> 
> To resolve this, adding code so that we do not pad FCoE frames prior to
> handling them to the stack.
> 
> CC: <stable@vger.kernel.org>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
