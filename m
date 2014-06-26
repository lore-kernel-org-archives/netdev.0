From: Daniel Mack <daniel@zonque.org>
Subject: Re: [BUG] Circular dependency introduced in commit 86f6cf4127
Date: Thu, 26 Jun 2014 09:11:52 +0200
Message-ID: <53ABC7B8.6060808@zonque.org>
References: <53AAEE62.7010602@suse.com> <20140625.154057.1098838428988383751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:40798 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753358AbaFZHLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 03:11:55 -0400
In-Reply-To: <20140625.154057.1098838428988383751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2014 12:40 AM, David Miller wrote:
> From: Jeff Mahoney <jeffm@suse.com>
> Date: Wed, 25 Jun 2014 11:44:34 -0400
> 
>> Commit 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev())
>> introduced a circular dependency between libphy and of_mdio.
>>
>> depmod: ERROR: <modroot>/kernel/drivers/net/phy/libphy.ko in
>> dependency cycle!
>> depmod: ERROR: <modroot>/kernel/drivers/of/of_mdio.ko in dependency cycle!
> 
> Yeah, of_mdio.c references &mdio_bus_type and libphy now references
> of_mdiobus_link_phydev.
> 
> Daniel, please work on fixing this, thanks.
> 

Patch sent. Apologies for the breakage!


Daniel
