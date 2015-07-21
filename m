From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netcp: fix improper initialization in
 netcp_ndo_open()
Date: Mon, 20 Jul 2015 20:38:06 -0700 (PDT)
Message-ID: <20150720.203806.2301067437587964745.davem@davemloft.net>
References: <1437075134-24423-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	w-kwok2@ti.com
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437075134-24423-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Thu, 16 Jul 2015 15:32:14 -0400

> The keystone qmss will raise interrupt when packet arrive at the
> receive queue. Only control available to avoid interrupt from happening
> is to keep the free descriptor queue (FDQ) empty in the receive side.
> So the filling of descriptors into the FDQ has to happen after
> request_irq() call is made as part of knav_queue_enable_notify(). So
> move the function netcp_rxpool_refill() after this call.
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

Applied, thanks.
