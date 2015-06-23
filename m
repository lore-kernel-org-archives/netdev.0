From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/1] net: fec: init MAC prior to mii bus
 probe
Date: Tue, 23 Jun 2015 07:11:23 -0700 (PDT)
Message-ID: <20150623.071123.2266348029568993238.davem@davemloft.net>
References: <1435044771-22828-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Frank.Li@freescale.com
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186AbbFWN7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:59:33 -0400
In-Reply-To: <1435044771-22828-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>
Date: Tue, 23 Jun 2015 15:32:51 +0800

> Below case causes mii bus probe failed:
> ifconfig eth0 down -> suspend/resume with Mega/fax mix off -> ifconfig eth0 up
> 
> In i.MX6SX/i.MX7D chip, Mega/fast mix off feature is supported that means most of
> SOC power will be off including ENET MAC for power saving. Once ENET MAC power
> off, all initialized MAC registers reset to default, so in the case, it must
> init MAC prior to mii bus probe.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied.
