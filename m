From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/macb: fix race with RX interrupt while doing NAPI
Date: Wed, 13 Feb 2013 13:36:03 -0500 (EST)
Message-ID: <20130213.133603.392678696679169085.davem@davemloft.net>
References: <50D2D7BD.3030801@erwinrol.com>
	<1360663728-10296-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, plagnioj@jcrosoft.com,
	mailinglists@erwinrol.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360663728-10296-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Tue, 12 Feb 2013 11:08:48 +0100

> When interrupts are disabled, an RX condition can occur but
> it is not reported when enabling interrupts again. We need to check
> RSR and use napi_reschedule() if condition is met.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied.
