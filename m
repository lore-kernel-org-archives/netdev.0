From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/38] rndis_wlan: fix checking for default value
Date: Tue, 22 Sep 2015 16:15:24 -0700 (PDT)
Message-ID: <20150922.161524.1515837996577333930.davem@davemloft.net>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
	<1442842450-29769-24-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, jussi.kivilinna@iki.fi,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442842450-29769-24-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Mon, 21 Sep 2015 15:33:55 +0200

> Thresholds uses -1 to indicate that default value should be used.
> Since thresholds are unsigned sign checking makes no sense.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2038576
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Applied.
