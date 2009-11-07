From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ems_usb: Fix byte order issues on big endian machines
Date: Fri, 06 Nov 2009 20:26:37 -0800 (PST)
Message-ID: <20091106.202637.214421435.davem@davemloft.net>
References: <20091104154824.18199.15573.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: haas@ems-wuensche.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760185AbZKGE0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:26:11 -0500
In-Reply-To: <20091104154824.18199.15573.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Haas <haas@ems-wuensche.com>
Date: Wed, 04 Nov 2009 16:48:24 +0100

> CPC-USB is using a ARM7 core with little endian byte order. The "id" field
> in can_msg needs byte order conversion from/to CPU byte order.
> 
> Signed-off-by: Sebastian Haas <haas@ems-wuensche.com>

Applied to net-2.6
