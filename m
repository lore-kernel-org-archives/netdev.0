From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/cadence: don't build by default
Date: Thu, 31 Jan 2013 13:57:23 -0500 (EST)
Message-ID: <20130131.135723.1501528815124767623.davem@davemloft.net>
References: <1359656815-27919-1-git-send-email-riccardo.magliocchetti@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: riccardo.magliocchetti@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab3AaS5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 13:57:25 -0500
In-Reply-To: <1359656815-27919-1-git-send-email-riccardo.magliocchetti@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
Date: Thu, 31 Jan 2013 19:26:55 +0100

> No need to build net/cadence driver by default.
> 
> Signed-off-by: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>

Vendor guards are set yes on purpose, because it mimicks for compatability
the behavior that existed before the vendor guards were in place.

These checks guard families of drivers from being offered, rather than
the drivers themselves.

I'm not applying this patch.
