From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: add phy_reset parameter
Date: Sun, 21 Jun 2009 14:29:30 -0700 (PDT)
Message-ID: <20090621.142930.251405926.davem@davemloft.net>
References: <4A3E7FC5.6060400@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com
To: simon@fire.lp0.eu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755766AbZFUV3h@vger.kernel.org>
In-Reply-To: <4A3E7FC5.6060400@simon.arlott.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Arlott <simon@fire.lp0.eu>
Date: Sun, 21 Jun 2009 19:45:25 +0100

> When booting over the network the physical link will already be up
> and configured appropriately, so there is no need to reset it and
> cause auto-negotiation to occur again. Adding an option to disable
> this makes it possible to avoid a 2 second delay while booting.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

This is getting out of control.

We're not going to add a hundred different obscure module options to
eliminate delays and device resets.
