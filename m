From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netdev: New driver for OCTEON's MGMT ethernet
 devices.
Date: Thu, 25 Dec 2008 16:52:19 -0800 (PST)
Message-ID: <20081225.165219.83442602.davem@davemloft.net>
References: <494C312E.9000901@caviumnetworks.com>
	<1229730192-11870-3-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55720
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752180AbYLZAwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:52:17 -0500
In-Reply-To: <1229730192-11870-3-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Fri, 19 Dec 2008 15:43:12 -0800

> +#define CVMX_MDIO_PHY_REG_CONTROL 0
> +union cvmx_mdio_phy_reg_control {
> +	uint16_t u16;
> +	struct {
> +		uint16_t reset:1;
> +		uint16_t loopback:1;
> +		uint16_t speed_lsb:1;

Please use the standard Linux in-kernel types for fixed sized
integers, such as u16, u32, etc.

Having a union member named the same as a standard type defined in the
kernel is very confusing.
