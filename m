From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Default offload settings in Ethernet drivers
Date: Thu, 11 Dec 2008 19:52:48 +0000
Message-ID: <1229025168.3006.41.camel@achroite>
References: <49415EDB.3030006@computer.org> <20081211105459.3e615be8@s6510>
	 <49416A4B.7060205@computer.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35444 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756540AbYLKTwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 14:52:54 -0500
In-Reply-To: <49416A4B.7060205@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-11 at 20:30 +0100, Jan Ceuleers wrote:
> Stephen Hemminger wrote:
> > I don't think there will be any difference. Linux (mainline) doesn't
> > do TOE. It does do segmentation offload, and any driver that can
> > do segmentation offload enables it by default.
> 
> Stephen,
> 
> Thanks for your reply. My experience with the r8169 driver is that it 
> does support rx checksumming, tx checksumming, scatter/gather and tcp 
> segmentation, but out of the above only enables rx checksumming by default.
> 
> The other two ethernet drivers I have hardware for don't support any 
> hardware-assisted offloads (that is: they all support generic 
> segmentation offload but that isn't hardware-assisted and it is also not 
> enabled by default).

Since v2.6.27, GSO is enabled by default for devices that can do TX
scatter/gather and checksum offload.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

