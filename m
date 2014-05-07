From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qlcnic: Fix Kconfig dependency on HWMON
Date: Wed, 07 May 2014 17:23:48 -0400 (EDT)
Message-ID: <20140507.172348.946895436076177246.davem@davemloft.net>
References: <1399442775-20610-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shahed.shaikh@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com, arnd@arndb.de
To: harish.patil@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbaEGVXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:23:51 -0400
In-Reply-To: <1399442775-20610-1-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>
Date: Wed, 7 May 2014 02:06:15 -0400

> Commit 1f0f467b670e "qlcnic: Add hwmon interface to export board
> temperature" introduced a randconfig build error in the case
> when the hwmon framework is built as a module and the qlcnic
> driver itself is built-in:
> 
> drivers/built-in.o: In function `qlcnic_register_hwmon_dev':
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c:1301:
> undefined reference to `hwmon_device_register_with_groups'
> drivers/built-in.o: In function `qlcnic_unregister_hwmon_dev':
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c:1309:
> undefined reference to `hwmon_device_unregister'.
> 
> This changes the Kconfig logic to enforce that the qlcnic hwmon
> support can only be enabled if it is possible to successfully
> build it.
> 
> Signed-off-by: Harish Patil <harish.patil@qlogic.com>
> Reported-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks for following up on this.
