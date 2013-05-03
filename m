From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: tg3 adapter losing link - PM related?
Date: Fri, 3 May 2013 19:39:50 +0100
Message-ID: <1367606390.2756.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130503092846.GA5126@pcnci.linuxbox.cz>
	 <5183D40B.8090605@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nikola Ciprich <nikola.ciprich@linuxbox.cz>,
	<netdev@vger.kernel.org>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58082 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758398Ab3ECSjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 14:39:54 -0400
In-Reply-To: <5183D40B.8090605@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 08:13 -0700, Nithin Nayak Sujir wrote:
> Hi Nikola,
> 1. What device is present on this server? Can you give the tg3 messages 
> in /var/log/messages? Can you also give the output of "ethtool -i <iface>"?
> 
> 2. Is it possible for you to try the latest 3.9 upstream kernel?
> 
> 3. Any reason why the link is at 100Mb? The switch does not support gig? 
> What switch is it?
> 
> 4. I don't think you can turn off EEE in the bios, but you can try 
> turning autoneg off. Try "ethtool -s <iface> speed 100 duplex full 
> autoneg off". It's not exactly the same thing since the device still has 
> EEE enabled but not negotiated.
[...]

It should be possible to disable EEE with ethtool.  You really should
implement the EEE configuration operations in tg3 if you're going to
enable it at all.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
