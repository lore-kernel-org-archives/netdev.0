From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] mv643xx_eth with 88E1318S: support Wake
 on LAN
Date: Tue, 12 Mar 2013 11:41:25 -0400 (EDT)
Message-ID: <20130312.114125.1254938887790170022.davem@davemloft.net>
References: <1363046205-17239-1-git-send-email-michael@stapelberg.de>
	<1363046205-17239-2-git-send-email-michael@stapelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com
To: michael@stapelberg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550Ab3CLPlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:41:14 -0400
In-Reply-To: <1363046205-17239-2-git-send-email-michael@stapelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Stapelberg <michael@stapelberg.de>
Date: Tue, 12 Mar 2013 00:56:45 +0100

> This has been tested on a qnap TS-119P II. Note that enabling WOL with
> "ethtool -s eth0 wol g" is not enough; you also need to tell the PIC
> microcontroller inside the qnap that WOL should be enabled by sending
> 0xF2 with qcontrol(1) and you have to disable EUP ("Energy-using
> Products", a European power-saving thing) by sending 0xF4.
> 
> Signed-off-by: Michael Stapelberg <michael@stapelberg.de>

Applied.
