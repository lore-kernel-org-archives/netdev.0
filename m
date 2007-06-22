From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Fri, 22 Jun 2007 13:02:32 +0200
Message-ID: <467BAC48.1070700@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de> <20070622034703.28886.5@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60913 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbXFVLDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 07:03:09 -0400
In-Reply-To: <20070622034703.28886.5@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> This patch adds the virtual CAN bus (vcan) network driver.
> The vcan device is just a loopback device for CAN frames, no
> real CAN hardware is involved.


Is there a reason why you're still doing the "allocate n devices
on init" thing instead of using the rtnl_link API?
