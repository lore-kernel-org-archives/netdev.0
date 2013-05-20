From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: usb: rtl8150: concurrent URB bugfix
Date: Mon, 20 May 2013 13:42:32 -0700 (PDT)
Message-ID: <20130520.134232.344940542336017991.davem@davemloft.net>
References: <alpine.DEB.2.02.1305201152001.11943@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com
To: petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1305201152001.11943@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>
Date: Mon, 20 May 2013 12:08:47 +0300 (EEST)

> From: Petko Manolov <petkan@nucleusys.com>
> 
> This patch fixes a potential race with concurrently running asynchronous 
> write requests.  The values for device's RX control register are now 
> stored in dynamically allocated buffers so each URB submission has it's 
> own copy.  Doing it the old way is data clobbering prone.
> 
> This patch is against latest 'net' tree.
> 
> Signed-off-by: Petko Manolov <petkan@nucleusys.com>

Applied, thanks.
