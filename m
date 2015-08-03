From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add BQL support for 3c59x, based on patch from Tino
 Reichardt.
Date: Mon, 03 Aug 2015 15:08:52 -0700 (PDT)
Message-ID: <20150803.150852.867812396910913708.davem@davemloft.net>
References: <20150801061313.GA12571@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: logan@elandsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426AbbHCWIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 18:08:54 -0400
In-Reply-To: <20150801061313.GA12571@mx.elandsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Loganaden Velvindron <logan@elandsys.com>
Date: Fri, 31 Jul 2015 23:13:13 -0700

> Tested on 3Com PCI 3c905C Tornardo by running Flent multiple times.
> 
> Signed-off-by: Loganaden Velvindron <logan@elandsys.com>

Please format your Subject line correctly, it should be of
the form:

	[PATCH $TREE] $SUBSYSTEM: $DESCRIPTION.

Where "TREE" is either 'net' or 'net-next'.  "SUBSYSTEM" is the subsystem or
driver name being changed, which here should be '3c59x' and then the
title line descritpion of your patch.

Also, I am pretty sure you will need to add logic to
vortex_tx_timeout() since that resets the TX ring state.
