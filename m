From: Riku Voipio <riku.voipio@movial.fi>
Subject: Re: [i2c] SFC driver implements its own I2C support
Date: Thu, 15 May 2008 15:03:28 +0300
Message-ID: <482C2690.1000004@movial.fi>
References: <20080513103325.1ab317cf@hyperion.delvare> <20080514215818.GH28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Linux I2C <i2c@lm-sensors.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:63795 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbYEOMKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 08:10:08 -0400
In-Reply-To: <20080514215818.GH28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
>> Using the standard I2C implementation will give you access to all the
>> i2c debugging tools, user-space access to the I2C bus if needed, and
>> compatibility with all the Linux i2c device drivers, including hardware
>> monitoring and GPIO drivers which apparently the SFC hardware uses.
>>     
>
> Right.  But the most immediate requirement is that we be able to
> configure I2C devices from the sfc driver.  Most of our reference
> designs require that as part of their initialisation.

That's how many DVB adapter drivers already work. Although
I'm not sure which one would be cleanest and simplest example.
