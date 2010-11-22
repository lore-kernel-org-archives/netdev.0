From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: Fix incorrect usage of module parameters and
 netdev msg level
Date: Mon, 22 Nov 2010 08:29:43 -0800 (PST)
Message-ID: <20101122.082943.104076370.davem@davemloft.net>
References: <1290075903-3038-1-git-send-email-sonnyrao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, miltonm@bga.com, ron.mercer@qlogic.com,
	linux-driver@qlogic.com, linux-kernel@vger.kernel.org
To: sonnyrao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750790Ab0KVQ3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 11:29:18 -0500
In-Reply-To: <1290075903-3038-1-git-send-email-sonnyrao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonny Rao <sonnyrao@linux.vnet.ibm.com>
Date: Thu, 18 Nov 2010 04:25:03 -0600

> Driver appears to be mistaking the permission field with default value
> in the case of debug and qlge_irq_type.
> 
> Driver is also passing debug as a bitmask into netif_msg_init()
> which really wants a number of bits, so fix that.
> 
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Sonny Rao <sonnyrao@linux.vnet.ibm.com>

Applied, thanks Sonny.
