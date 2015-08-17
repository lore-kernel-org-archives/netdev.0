From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF
 is configured or used
Date: Mon, 17 Aug 2015 14:06:37 -0700 (PDT)
Message-ID: <20150817.140637.1398365618268358269.davem@davemloft.net>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeremy.linton@arm.com
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbbHQVGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:06:38 -0400
In-Reply-To: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Mon, 17 Aug 2015 13:45:36 -0700

> Commit 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT") makes
> the call to smsc911x_probe_config() unconditional, and no longer fails if
> there is no device node. device_get_phy_mode() is called unconditionally,
> and if there is no phy node configured returns an error code. This error
> code is assigned to phy_interface, and interpreted elsewhere in the code
> as valid phy mode. This in turn causes qemu to crash when running a
> variant of realview_pb_defconfig.
> 
> 	qemu: hardware error: lan9118_read: Bad reg 0x86
> 
> Fixes: 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT")
> Cc: Jeremy Linton <jeremy.linton@arm.com>
> Cc Graeme Gregory <graeme.gregory@linaro.org>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
