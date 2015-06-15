From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] [4.2] NFC update
Date: Mon, 15 Jun 2015 16:44:58 -0700 (PDT)
Message-ID: <20150615.164458.1884229248616341167.davem@davemloft.net>
References: <20150614160045.GA10440@ribalta.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-nfc@lists.01.org
To: sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbFOXo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:44:59 -0400
In-Reply-To: <20150614160045.GA10440@ribalta.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Ortiz <sameo@linux.intel.com>
Date: Sun, 14 Jun 2015 18:00:45 +0200

> This is the NFC pull request for 4.2:
> 
> - NCI drivers can now define their own handlers for processing
>   proprietary NCI responses and notifications.
> 
> - NFC vendors can use a dedicated netlink API to send their own
>   proprietary commands, like e.g. all commands needed to implement
>   vendor specific manufacturing tools.
> 
> - A new generic NCI over UART driver against which any NCI chipset
>   running on top of a serial interface can register.
> 
> - The st21nfcb driver is renamed to st-nci as it can and will support
>   most of ST Microelectronics NCI chipsets.
> 
> - The st21nfcb driver can put its CLF in hibernate mode and save
>   significant amount of power.
> 
> - A few st21nfcb minor fixes.
> 
> - The NXP NCI driver now supports ACPI enumeration.
> 
> - The Marvell NCI driver now supports both USB and serial
>   physical interfaces.
> 
> - The Marvell NCI drivers also supports NCI frames being muxed
>   over HCI. This is a setting that can be defined by a DT property.

Pulled, thanks Sam.
