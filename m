From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] sfc: Convert to use hwmon_device_register_with_groups
Date: Tue, 26 Nov 2013 19:34:50 -0800
Message-ID: <5295685A.7010707@roeck-us.net>
References: <1385523037-3774-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, lm-sensors@lm-sensors.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:53272 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3K0Dew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 22:34:52 -0500
In-Reply-To: <1385523037-3774-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2013 07:30 PM, Guenter Roeck wrote:
> Simplify the code. Avoid race conditions caused by attributes
> being created after hwmon device registration. Implicitly
> (through hwmon API) add mandatory 'name' sysfs attribute.
>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> Compile tested only.
>

Sorry for the noise if you see this patch multiple times. My send script tried to annoy me.

Guenter
