From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] net-next:asix: reduce AX88772 init time by about 2
 seconds
Date: Tue, 15 Nov 2011 16:41:53 -0500 (EST)
Message-ID: <20111115.164153.1285351501002169756.davem@davemloft.net>
References: <1321377163-26308-1-git-send-email-grundler@chromium.org>
	<1321377163-26308-3-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, freddy@asix.com.tw, grundler@google.com
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321377163-26308-3-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Tue, 15 Nov 2011 09:12:41 -0800

> From: Grant Grundler <grundler@google.com>
> 
> ax88772_reset takes about 2 seconds and is called twice.
> Once from ax88772_bind() directly and again indirectly from usbnet_open().
> Reset the USB FW/Phy enough to blink the LEDs when inserted.
> 
> Signed-off-by: Allan Chou <allan@asix.com.tw>
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied.
