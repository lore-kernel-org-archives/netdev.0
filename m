From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [UPDATED PATCH] igb: remove 82576 quad adapter
Date: Wed, 27 Aug 2008 05:37:17 -0400
Message-ID: <48B5204D.508@garzik.org>
References: <20080808235126.19264.39654.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59085 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887AbYH0JhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:37:20 -0400
In-Reply-To: <20080808235126.19264.39654.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Disable support for device 8086:10E8.  Currently the result of loading the
> driver with the device present causes system instability.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/igb/e1000_82575.c |    1 -
>  drivers/net/igb/e1000_hw.h    |    1 -
>  drivers/net/igb/igb_ethtool.c |    9 ---------
>  drivers/net/igb/igb_main.c    |   11 -----------
>  4 files changed, 0 insertions(+), 22 deletions(-)

applied


