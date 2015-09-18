From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND] ARCNET: fix hard_header_len limit
Date: Thu, 17 Sep 2015 22:27:14 -0700 (PDT)
Message-ID: <20150917.222714.700195258551388830.davem@davemloft.net>
References: <1442495914-26823-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442495914-26823-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Thu, 17 Sep 2015 15:18:34 +0200

> For arcnet the bare minimum header only contains the 4 bytes to
> specify source, dest and offset (1, 1 and 2 bytes respectively).
> The corresponding struct is struct arc_hardware.
> 
> The struct archdr contains additionally a union of possible soft
> headers. When doing $insertusecasehere packets might well
> include short (or even no?) soft headers.
> 
> For this reason only use arc_hardware instead of archdr to
> determine the hard_header_len for an arcnet device.
> 
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>

Applied.
