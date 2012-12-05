From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3com: make 3c59x depend on HAS_IOPORT
Date: Wed, 05 Dec 2012 15:22:15 -0500 (EST)
Message-ID: <20121205.152215.2131473855816601966.davem@davemloft.net>
References: <1354716280.29038.2.camel@hal>
	<20121205.125804.979819753893520607.davem@davemloft.net>
	<1354736666.14042.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab2LEUWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 15:22:18 -0500
In-Reply-To: <1354736666.14042.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Glauber <jang@linux.vnet.ibm.com>
Date: Wed, 05 Dec 2012 20:44:26 +0100

> On Wed, 2012-12-05 at 12:58 -0500, David Miller wrote:
>> From: Jan Glauber <jang@linux.vnet.ibm.com>
>> Date: Wed, 05 Dec 2012 15:04:40 +0100
>> 
>> > From: Jan Glauber <jang@linux.vnet.ibm.com>
>> > 
>> > The 3com driver for 3c59x requires ioport_map. Since not all
>> > architectures support IO port mapping make 3c59x dependent on HAS_IOPORT.
>> > 
>> > Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>
>> 
>> Which platforms support PCI or EISA yet do not set HAS_IOPORT?
>> 
> 
> s390. We wont get support for port I/O in the PCI hardware/firmware
> layer. (The patches for PCI on s390 are currently in linux-next).

Ok, I'll apply this to net-next, thanks.
