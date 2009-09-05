From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Sat, 05 Sep 2009 07:52:20 +0200
Message-ID: <1252129940.27694.9.camel@violet>
References: <1252109846.27694.1.camel@violet>
	 <20090904.202750.249172306.davem@davemloft.net>
	 <1252125240.27694.5.camel@violet>
	 <20090904.214615.198838334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	johannes@sipsolutions.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53645 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbZIEFwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 01:52:21 -0400
In-Reply-To: <20090904.214615.198838334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> > What is ugly about it. Do you have any other recommendation on how let
> > userspace know what type of Ethernet device it is?
> 
> Well, for one thing, you're wasting 48 bytes on 64-bit when all you're
> really intrested in is one string.

the integration with struct device has plenty of other advantages. You
could use all the sysfs magic from it. For example in the next step the
hacking of some sysfs directories can be moved into the subsystem itself
and could be moved out of the core. Wireless would be one of them were
we would benefit here.

> Also, you didn't setup an assignment for plain ethernet devices,
> you just handle the non-traditional devices that do ethernet
> framing.  Is this intentional?

For now it is. Mainly since some non plain Ethernet devices are using
alloc_etherdev instead of just alloc_netdev. So I would have to do some
extra work. I have planned it, but not gotten around it yet.

Regards

Marcel


