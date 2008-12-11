From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: interface counters overflow (ppp)
Date: Thu, 11 Dec 2008 18:15:53 +0000
Message-ID: <1229019353.3006.8.camel@achroite>
References: <200812112142.46202.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:35447 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754068AbYLKSQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 13:16:08 -0500
In-Reply-To: <200812112142.46202.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-12-11 at 21:42 +0200, Denys Fedoryschenko wrote:
> Is there any plans to convert ppp counters to 64-bit values?
> Sure backward compatible way. (new ioctl call?)
> 
> Current speeds on modern interfaces, even on 1Mbit DSL modem (PPPoE 
> connection) will overflow pppd counters just in ~10 hours.
> 
> Current pppd implementation using SIOCGPPPSTATS ioctl, where is all fields 
> related to byte counting is 32-bit.

Perhaps it could implement ethtool stats?  There are several non-
Ethernet drivers implementing some of the ethtool operations now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

