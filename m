From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Reset hardware address (MAC address) in c++
Date: Sun, 09 Jan 2011 16:06:53 +0000
Message-ID: <1294589213.3283.103.camel@localhost>
References: <AANLkTimW247sL7mVKChOVjGFTcSA4mYZhwXdasfaYzXN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chin Shi Hong <cshong87@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52673 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab1AIQHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:07:00 -0500
In-Reply-To: <AANLkTimW247sL7mVKChOVjGFTcSA4mYZhwXdasfaYzXN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-01-09 at 22:39 +0800, Chin Shi Hong wrote:
> Dear All,
> 
> My final year project is all about MAC address spoofing.
> 
> I do know that I can reset the MAC address of my network adapter to
> its original by rebooting the Linux operating system I am using.
> 
> My Linux distribution is using NetworkManager. On Wireless network,
> each time after I change the MAC address of my wireless network
> adapter and then connect to the wireless network, and then once I
> disconnect from wireless network, NetworkManager will reset the MAC
> address of my wireless network adapter to its original.
> 
> I had programmed my application to change the MAC address. Now, trying
> to implement the feature that reset the MAC address. I don't know
> whether NetworkManager record down the original MAC address of my
> Network Adapter or not. But, assume if NetworkManager is able to reset
> the MAC address of my network adapter to its original MAC address
> without recording the original MAC address and without reboot, then my
> application must be able to do the same.
> 
> So, can anyone tell me the C++ codes that is able to reset the MAC
> address, or give me some ideas on this, please?

You can read the permanent MAC address using the ethtool
ETHTOOL_GPERMADDR operation.  See the ethtool utility for an example of
how to use this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

