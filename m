From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/38] usbnet: remove invalid check
Date: Tue, 22 Sep 2015 16:15:02 -0700 (PDT)
Message-ID: <20150922.161502.272701111248740831.davem@davemloft.net>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
	<1442842450-29769-28-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, steve.glendinning@shawell.net,
	Woojung.Huh@microchip.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442842450-29769-28-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Mon, 21 Sep 2015 15:33:59 +0200

> skb->len is always non-negative.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2038576
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Applied.
