From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] qed*: Add support for read/write of eeprom
Date: Sun, 17 Apr 2016 19:18:49 -0400 (EDT)
Message-ID: <20160417.191849.2044093416855662399.davem@davemloft.net>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1460921195-23352-6-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sudarsana.kalluru@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbcDQXSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 19:18:52 -0400
In-Reply-To: <1460921195-23352-6-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 17 Apr 2016 22:26:35 +0300

> There's quite a bit of `magic' here [based on the ethtool `magic'
> field] which is retained by the user application responsible for
> interacting with the driver for the purpose of upgrading the nvram
> image.

This is not how the 'magic' value of the eeprom structure is specified
to be used, please use it the way it is supposed to be used rather
than inventing semantics which only apply to your device.

The entire point of defining a common interface for device driver
interface interaction with the user is exactly so that driver authors
don't do things like this.
