From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] igb: fix tx data corruption with transition to L0s on
 82575
Date: Tue, 21 Oct 2008 02:11:13 -0400
Message-ID: <48FD7281.6030601@garzik.org>
References: <20081017042657.7080.17171.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46196 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427AbYJUGLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 02:11:17 -0400
In-Reply-To: <20081017042657.7080.17171.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The 82575 has an issue in which the DMA will go out of sync if the link
> partner goes into an L0s state.  To prevent this we set the pci-e link
> partner capability bits to disable the L0s transition on the hw.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/igb/igb_main.c |   27 +++++++++++++++++++++++++--
>  1 files changed, 25 insertions(+), 2 deletions(-)

applied


