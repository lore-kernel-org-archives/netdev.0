From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25.3 1/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Wed, 25 Jun 2008 22:55:50 -0700 (PDT)
Message-ID: <20080625.225550.199765051.davem@davemloft.net>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE603B863@SHEXMB-01.global.atheros.com>
	<20080625224829.3c6f4789@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jie.Yang@Atheros.com, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58046
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752209AbYFZFzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 01:55:50 -0400
In-Reply-To: <20080625224829.3c6f4789@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 25 Jun 2008 22:48:29 -0700

> I would prefer that the driver be NAPI only, because configuration
> choices are hard for users and distribution to make correct
> choice. Plus it means two choices for your QA to test.

I agree with Stephen.

It's absolutely to provide a non-NAPI option, please just remove
the option and the conditionals from the code.
