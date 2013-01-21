From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/33] net: Convert to devm_ioremap_resource()
Date: Mon, 21 Jan 2013 15:29:13 -0500 (EST)
Message-ID: <20130121.152913.1377695352860141642.davem@davemloft.net>
References: <1358762966-20791-1-git-send-email-thierry.reding@avionic-design.de>
	<1358762966-20791-21-git-send-email-thierry.reding@avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	dmitry.torokhov@gmail.com, arnd@arndb.de, w.sang@pengutronix.de,
	netdev@vger.kernel.org
To: thierry.reding@avionic-design.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358762966-20791-21-git-send-email-thierry.reding@avionic-design.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@avionic-design.de>
Date: Mon, 21 Jan 2013 11:09:13 +0100

> Convert all uses of devm_request_and_ioremap() to the newly introduced
> devm_ioremap_resource() which provides more consistent error handling.
> 
> devm_ioremap_resource() provides its own error messages so all explicit
> error messages can be removed from the failure code paths.
> 
> Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>

This won't compile if I apply it.

You really have to be clear when you submit patches like this.

Since you only CC:'d the networking developers for this one
patch, there is _ZERO_ context for us to work with to understand
what's going on.

You have to also CC: us on the other relevant changes and your
"[PATCH 00/33]" posting that explains what is happening.
