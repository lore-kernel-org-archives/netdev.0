From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb/kaweth: use GFP_ATOMIC under spin_lock in
 usb_start_wait_urb()
Date: Mon, 12 Jan 2015 16:43:15 -0500 (EST)
Message-ID: <20150112.164315.1318481358364498844.davem@davemloft.net>
References: <1420845382-25815-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420845382-25815-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 10 Jan 2015 02:16:22 +0300

> Commit e4c7f259c5be ("USB: kaweth.c: use GFP_ATOMIC under spin_lock")
> makes sure that kaweth_internal_control_msg() allocates memory with GFP_ATOMIC,
> but kaweth_internal_control_msg() also calls usb_start_wait_urb()
> that still allocates memory with GFP_NOIO.
> 
> The patch fixes usb_start_wait_urb() as well.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.
