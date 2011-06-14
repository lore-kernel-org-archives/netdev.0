From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Tue, 14 Jun 2011 13:32:00 -0400 (EDT)
Message-ID: <20110614.133200.1595212089561436266.davem@davemloft.net>
References: <201106141432.32257.vladz@broadcom.com>
	<20110614.115402.426774711287563448.davem@davemloft.net>
	<201106141922.40906.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, bprakash@broadcom.com, eilong@broadcom.com,
	netdev@vger.kernel.org, dmitry@broadcom.com,
	yaniv.rosner@broadcom.com, dwmw2@infradead.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab1FNRdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 13:33:11 -0400
In-Reply-To: <201106141922.40906.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Tue, 14 Jun 2011 19:22:40 +0300

> On Tuesday 14 June 2011 18:54:02 David Miller wrote:
>> From: "Vlad Zolotarov" <vladz@broadcom.com>
>> Date: Tue, 14 Jun 2011 14:32:31 +0300
>> 
>> > We also send the new FW files to David Woodhouse. It's the first time we
>> > submit to the linux-firmware git so I hope we don't mess the things up:
>> > we DO NOT patch firmware/WHENCE and firmware/Makefile files in our
>> > net-next patches and we patch the WHENCE file in the linux-firmware
>> > patch. Dave, pls., confirm if it's a correct procedure.
>> > 
>> > If it is, pls., note that the bnx2x driver will compile but won't work
>> > until u integrate the new FW into the kernel tree.
>> 
>> David Woodhouse, what do you think we should do here?
>> 
>> I'm inclined to integrate the firmware into net-next-2.6 since this
>> is the only way to keep the driver working consistently.
>> 
>> Otherwise people won't be able to git bisect properly, and that sucks.
> 
> Dave, as long as /lib/firmware contains all existing firmwares there should be 
> no problems, isn't it?

You're saying above that the driver will compile but not work in net-next-2.6
until the FW is integrated, that's not acceptable, the tree must be fully
bisectable for people trying to track down bugs.

Which is it?
