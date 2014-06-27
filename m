From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: [PATCH 2/2] rsi: fix memory leaks and error handling in rsi_91x_usb
Date: Fri, 27 Jun 2014 12:17:37 +0200
Message-ID: <CAOiHx=npgf-YczNVeiZ25Nh8yGeOVvvzT4Hvt2ocL705wexUYQ@mail.gmail.com>
References: <1403823085-10464-1-git-send-email-khoroshilov@ispras.ru> <1403823085-10464-2-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Fariya Fatima <fariyaf@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403823085-10464-2-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2014 at 12:51 AM, Alexey Khoroshilov
<khoroshilov@ispras.ru> wrote:
> The patch fixes a couple of issues:
> - absence of deallocation of rsi_dev->rx_usb_urb[0] in the driver;
> - potential NULL pointer dereference because of lack of checks for memory
>   allocation success in rsi_init_usb_interface().
>
> By the way, it makes rsi_probe() returning error code instead of 1
> and fixes comments regarding returning values.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

I count four different issues being fixed, so maybe split this into
four patches?


Regards
Jonas
