From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usb/kaweth: use GFP_ATOMIC under spin_lock in
 usb_start_wait_urb()
Date: Mon, 12 Jan 2015 13:37:10 +0100
Message-ID: <1421066230.12454.24.camel@linux-0dmf.site>
References: <1420845382-25815-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420845382-25815-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-01-10 at 02:16 +0300, Alexey Khoroshilov wrote:
> Commit e4c7f259c5be ("USB: kaweth.c: use GFP_ATOMIC under spin_lock")
> makes sure that kaweth_internal_control_msg() allocates memory with
> GFP_ATOMIC,
> but kaweth_internal_control_msg() also calls usb_start_wait_urb()
> that still allocates memory with GFP_NOIO.
> 
> The patch fixes usb_start_wait_urb() as well.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Acked-by: Oliver Neukum <oliver@neukum.org>
