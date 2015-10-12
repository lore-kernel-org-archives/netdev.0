From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH] driver: net: cpsw: add no_bd_ram dt parsing
Date: Mon, 12 Oct 2015 13:50:48 +0530
Message-ID: <561B6D60.9060301@ti.com>
References: <1444385206-7011-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Sekhar Nori <nsekhar@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:57313 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbbJLIV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2015 04:21:28 -0400
In-Reply-To: <1444385206-7011-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 October 2015 03:36 PM, Mugunthan V N wrote:
> cpdma is capable of placing the dma descriptors in ddr using
> dma_alloc_coherent() when the internal bd ram size is not enough.
> To utilize this feature pass the DT parameter "no_bd_ram" and
> increase bd_ram_size and number of rx descriptors.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Dave

Please drop this patch as it is not working on AM437x platform. Will
send a v2 after fixing it.

Regards
Mugunthan V N
