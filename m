From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Fri, 04 Sep 2009 21:46:15 -0700 (PDT)
Message-ID: <20090904.214615.198838334.davem@davemloft.net>
References: <1252109846.27694.1.camel@violet>
	<20090904.202750.249172306.davem@davemloft.net>
	<1252125240.27694.5.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41376
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbZIEEqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 00:46:00 -0400
In-Reply-To: <1252125240.27694.5.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sat, 05 Sep 2009 06:34:00 +0200

> What is ugly about it. Do you have any other recommendation on how let
> userspace know what type of Ethernet device it is?

Well, for one thing, you're wasting 48 bytes on 64-bit when all you're
really intrested in is one string.

Also, you didn't setup an assignment for plain ethernet devices,
you just handle the non-traditional devices that do ethernet
framing.  Is this intentional?
