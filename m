From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sfc: Convert to use
 hwmon_device_register_with_groups
Date: Fri, 29 Nov 2013 16:26:45 -0500 (EST)
Message-ID: <20131129.162645.721442484846350724.davem@davemloft.net>
References: <1385607271-11842-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	bhutchings@solarflare.com, lm-sensors@lm-sensors.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab3K2V0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:26:47 -0500
In-Reply-To: <1385607271-11842-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 27 Nov 2013 18:54:31 -0800

> Simplify the code. Avoid race conditions caused by attributes
> being created after hwmon device registration. Implicitly
> (through hwmon API) add mandatory 'name' sysfs attribute.
> 
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
