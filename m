From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/4] net: dsa: bcm_sf2: Add VLAN support
Date: Fri, 10 Jun 2016 15:04:51 -0400
Message-ID: <8760tgg90s.fsf@ketchup.mtl.sfl>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com> <1465519328-14249-5-git-send-email-f.fainelli@gmail.com> <20160610120046.GB2338@lunn.ch> <575B0B54.7030305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@mellanox.com,
	idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58601 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbcFJTEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 15:04:54 -0400
In-Reply-To: <575B0B54.7030305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Another possible approach would have been to allocate the vlan structure
> upong port_vlan_prepare() though that would typically result in more
> fragmentation over time once se start using more VLANs.

This is indeed what the switchdev prepare phase is for. If anything goes
wrong before calling the commit phase, switchdev will free the allocated
data.

Thanks,

        Vivien
