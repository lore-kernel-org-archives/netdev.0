From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: add Fast Ethernet driver for PXA168.
Date: Tue, 10 Aug 2010 16:42:52 -0700 (PDT)
Message-ID: <20100810.164252.52176926.davem@davemloft.net>
References: <6546F80B-0B5E-4F41-A500-7B75493A42DE@marvell.com>
	<20100810180154.GD25474@mail.wantstofly.org>
	<847F8195-87A2-4318-9E07-FF8A7E9FA1E6@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, ssanap@marvell.com, netdev@vger.kernel.org,
	akarkare@marvell.com, sarnaik@marvell.com, eric.y.miao@gmail.com,
	markb@marvell.com
To: prakity@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752795Ab0HJXmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 19:42:33 -0400
In-Reply-To: <847F8195-87A2-4318-9E07-FF8A7E9FA1E6@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Rakity <prakity@marvell.com>
Date: Tue, 10 Aug 2010 11:12:45 -0700

> Maybe the solution is to add a new option in Kconfig to define the
> extra headers size the driver will need.  That option will increase
> the headers.  I do not like that very much since it requires someone
> know how big the value should be.  Could default it to 48 or 64
> bytes and allow it to be edited.  It is not great solution since it
> fixes the pxa168 driver but does not handle other drivers.

Take a look at how we define LL_MAX_HEADER in include/linux/netdevice.h
