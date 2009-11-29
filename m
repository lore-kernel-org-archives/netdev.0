From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH v2] ep93xx-eth: check for zero MAC address on probe, not on device open
Date: Sun, 29 Nov 2009 13:11:58 +0100
Message-ID: <20091129121158.GV20214@mail.wantstofly.org>
References: <200911290057.02109.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:52187 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbZK2Ml0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 07:41:26 -0500
Content-Disposition: inline
In-Reply-To: <200911290057.02109.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 29, 2009 at 12:57:00AM +0100, Florian Fainelli wrote:

> If we happen to have registered the driver without passing
> a MAC address, we will print a zero MAC address and register
> the interface with this invalid address, this is confusin. This
> patch moves the checking of a valid ethernet address and the
> generation of a random one down from the open function to
> the probe function.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
