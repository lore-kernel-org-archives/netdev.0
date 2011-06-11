From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sat, 11 Jun 2011 16:29:42 -0700 (PDT)
Message-ID: <20110611.162942.1706711069327005315.davem@davemloft.net>
References: <20110611200625.GB14582@kroah.com>
	<1307829318-18246-1-git-send-email-marius@kotsbak.com>
	<20110611.162711.907394751613071878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	marius@kotsbak.com
To: marius.kotsbak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467Ab1FKX3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:29:45 -0400
In-Reply-To: <20110611.162711.907394751613071878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 11 Jun 2011 16:27:11 -0700 (PDT)

> From: "Marius B. Kotsbak" <marius.kotsbak@gmail.com>
> Date: Sat, 11 Jun 2011 23:55:18 +0200
> 
>> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
>> It has also an ACM interface that previous patches associates with the "option"
>> module. To access those interfaces, the modem must first be switched from modem
>> mode using a tool like usb_modeswitch.
>> 
>> As the proprietary protocol has been discovered by watching the MS Windows driver
>> behavior, there might be errors in the protocol handling, but stable and fast
>> connection has been established for hours with Norwegian operator NetCom that
>> distributes this modem with their LTE/4G subscription.
>> 
>> More and updated information about how to use this driver is available here:
>> 
>> http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=465
>> https://github.com/mkotsbak/Samsung-GT-B3730-linux-driver
>> 
>> Signed-off-by: Marius B. Kotsbak <marius@kotsbak.com>
> 
> Applied, thanks.

Actually, reverted.

There's a typo in your Makefile patch, and because of this it
won't even build the new driver.

People are so damn anxious to get this backported into stable
and various distributions, yet this patch wasn't even tested
properly.

That really drives me crazy.
