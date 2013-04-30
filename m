From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 2/4] be2net: Fix ethtool get drvinfo
Date: Tue, 30 Apr 2013 14:22:11 +0100
Message-ID: <1367328131.5106.62.camel@deadeye.wl.decadent.org.uk>
References: <6ecf8164-2cef-4a5a-9a18-5c1ba2c41f7c@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: Somnath Kotur <somnath.kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14987 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760460Ab3D3NWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 09:22:19 -0400
In-Reply-To: <6ecf8164-2cef-4a5a-9a18-5c1ba2c41f7c@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 17:07 +0530, Somnath Kotur wrote:
> From: Kalesh AP <kalesh.purayil@emulex.com>
> 
> Cannot issue any other mailbox command while firmware download is in progress.
> The get_drvinfo ethtool hook can be invoked without acquiring any rtnl_lock.
[...]

Although I documented that as being possible in ethtool.h, that was only
because of one particular caller that has since been removed (commit
e52ac3398c3d 'net: Use device model to get driver name in
skb_gso_segment()').  So unless I missed another case, you could change
the documentation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
