From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/usb/catc.c: Fix potential deadlock in
 catc_ctrl_run()
Date: Tue, 31 May 2011 15:30:30 -0700 (PDT)
Message-ID: <20110531.153030.224764258.davem@davemloft.net>
References: <1306774878-5471-1-git-send-email-khoroshilov@ispras.ru>
	<1306775184-5520-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306775184-5520-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Mon, 30 May 2011 21:06:24 +0400

> catc_ctrl_run() calls usb_submit_urb() with GFP_KERNEL, while it is called from
> catc_ctrl_async() and catc_ctrl_done() with catc->ctrl_lock spinlock held.
> 
> The patch replaces GFP_KERNEL with GFP_ATOMIC.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied.
