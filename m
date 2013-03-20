From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: ipconfig: Fix newline handling in log message.
Date: Wed, 20 Mar 2013 12:16:23 -0400 (EDT)
Message-ID: <20130320.121623.645763738994684687.davem@davemloft.net>
References: <20130319181929.10606.24517.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mfuzzey@parkeon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3CTQQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:16:25 -0400
In-Reply-To: <20130319181929.10606.24517.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Fuzzey <mfuzzey@parkeon.com>
Date: Tue, 19 Mar 2013 19:19:29 +0100

> When using ipconfig the logs currently look like:
> 
> Single name server:
> [    3.467270] IP-Config: Complete:
> [    3.470613]      device=eth0, hwaddr=ac:de:48:00:00:01, ipaddr=172.16.42.2, mask=255.255.255.0, gw=172.16.42.1
> [    3.480670]      host=infigo-1, domain=, nis-domain=(none)
> [    3.486166]      bootserver=172.16.42.1, rootserver=172.16.42.1, rootpath=
> [    3.492910]      nameserver0=172.16.42.1[    3.496853] ALSA device list:
> 
> Three name servers:
> [    3.496949] IP-Config: Complete:
> [    3.500293]      device=eth0, hwaddr=ac:de:48:00:00:01, ipaddr=172.16.42.2, mask=255.255.255.0, gw=172.16.42.1
> [    3.510367]      host=infigo-1, domain=, nis-domain=(none)
> [    3.515864]      bootserver=172.16.42.1, rootserver=172.16.42.1, rootpath=
> [    3.522635]      nameserver0=172.16.42.1, nameserver1=172.16.42.100
> [    3.529149] , nameserver2=172.16.42.200
> 
> Fix newline handling for these cases
> 
> Signed-off-by: Martin Fuzzey <mfuzzey@parkeon.com>

Applied, thanks.
