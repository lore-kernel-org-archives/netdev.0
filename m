From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] p54usb: fix leaks at failure path in p54u_probe()
Date: Fri, 07 Mar 2014 22:27:34 +0100
Message-ID: <2146611.esrnhmtufH@debian64>
References: <1394226709-10763-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394226709-10763-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, March 08, 2014 01:11:49 AM Alexey Khoroshilov wrote:
> If p54u_load_firmware() fails, p54u_probe() does not deallocate
> already allocated resources. The patch adds proper failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Acked-by: Christian Lamparter <chunkeey@googlemail.com>
