From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/5] igb: fix setting the number of tx queues
Date: Wed, 27 Aug 2008 05:18:59 -0400
Message-ID: <48B51C03.8090807@garzik.org>
References: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com> <20080826112513.15627.24776.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45247 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753800AbYH0JTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:19:02 -0400
In-Reply-To: <20080826112513.15627.24776.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The real_num_tx_queues was not being set when in MSI-X only mode.  This patch
> corrects that path so all interrupt types are correctly configured.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/igb/igb_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied 1, 2, and 5

patches 3 and 4 did not look like -rc4 material


