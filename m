From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 3.0.0rc6: ethtool not working without a cable
Date: Wed, 06 Jul 2011 15:28:04 +0100
Message-ID: <1309962484.4280.25.camel@localhost>
References: <201107061338.08573.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55362 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979Ab1GFO2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 10:28:09 -0400
In-Reply-To: <201107061338.08573.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-06 at 13:38 +0200, Arkadiusz Miskiewicz wrote:
> 3.0.0rc6, thinkpad t400 notebook.
> 
> If there is no cable then ethtool reports no device. It wasn't that before 
> AFAIK.
> 
> ethtool version 2.6.36
> 
> 
> cable disconnected:
> 
> [root@t400 ~]# ethtool eth0
> Settings for eth0:
> Cannot get device settings: No such device
> Cannot get wake-on-lan settings: No such device
> Cannot get message level: No such device
> Cannot get link status: No such device
> No data available
> zsh: exit 75    ethtool eth0
> [root@t400 ~]# ethtool -i eth0
> Cannot get driver information: No such device
> zsh: exit 71    ethtool -i eth0
[...]

Then there really isn't a device under that name.  Maybe the driver is
getting a bogus MAC address, so that the device is renamed by udev.

Check which devices do exist, and the MAC addresses they have, using 'ip
link'.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

