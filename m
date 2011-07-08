From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/natsemi: Fix module parameter permissions
Date: Fri, 08 Jul 2011 09:05:56 -0700 (PDT)
Message-ID: <20110708.090556.1065709849750465470.davem@davemloft.net>
References: <201107081101.28812.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thockin@hockin.org,
	broonie@opensource.wolfsonmicro.com
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab1GHQGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 12:06:07 -0400
In-Reply-To: <201107081101.28812.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Fri, 8 Jul 2011 11:01:28 +0200

> The third parameter of module_param is supposed to represent sysfs
> file permissions. A value of "1" leads to the following:
> 
> $ ls -l /sys/module/natsemi/parameters/
> total 0
> ---------x 1 root root 4096 Jul  8 09:46 dspcfg_workaround
> 
> I am changing it to "0" to align with the other module parameters in
> this driver.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied, thanks.
