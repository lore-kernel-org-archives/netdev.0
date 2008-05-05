From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH 1/2][ATM]: Do not free already unregistered net device.
Date: Mon, 05 May 2008 09:44:40 -0700
Message-ID: <1210005880.5716.4.camel@Linux.home>
Reply-To: davem@davemloft.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:43981 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354AbYEEQpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 12:45:25 -0400
Received: from [192.168.1.3] ([72.90.101.98])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0K0E0014YMQ6R0D2@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Mon, 05 May 2008 11:49:18 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do not understand why this change was accepted.  All of the network
drivers I just looked at in 2.6.25 do unregister_netdev() followed
sometime soon by free_netdev().  Is there something different about ATM
devices?  I did not look at all the drivers.

Don

