From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [stable] [PATCH] forcedeth: limit tx to 16
Date: Tue, 11 Mar 2008 11:16:37 -0700
Message-ID: <20080311181630.GQ4416@sequoia.sous-sol.org>
References: <47D592DD.4070300@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>, stable@kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:52210 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbYCKTdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2008 15:33:32 -0400
Content-Disposition: inline
In-Reply-To: <47D592DD.4070300@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ayaz Abdulla (aabdulla@nvidia.com) wrote:
> This is a critical patch which adds a workaround for a HW bug. The patch 
> will limit the number of outstanding tx packets to 16. Otherwise, the HW 
> could send out packets with bad checksums.
>
> The driver will still setup the tx packets into the ring, however, will 
> only set the Valid bit on 16 packets at a time.
>
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

BTW, if you add "Cc: <stable@kernel.org>" to the patch commitlog we stand
a chance of automagically picking it up when it is committed upstream
(Andrew does this already, but not if it goes in via another route).

thanks,
-chris
