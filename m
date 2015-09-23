From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: Fix Marvell Egress Trailer check
Date: Tue, 22 Sep 2015 17:37:30 -0700 (PDT)
Message-ID: <20150922.173730.247673648999969684.davem@davemloft.net>
References: <56011F2E.5080208@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56011F2E.5080208@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Tue, 22 Sep 2015 11:28:14 +0200

> The Marvell Egress rx trailer check must be fixed to
> correctly detect bad bits in the third byte of the
> Eggress trailer as described in the Table 28 of the
> 88E6060 datasheet.
> The current code incorrectly omits to check the third
> byte and checks the fourth byte twice.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Applied, thanks.
