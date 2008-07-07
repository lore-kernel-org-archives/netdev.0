From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 00/06]: VLAN TCI truncation fixes
Date: Sun, 06 Jul 2008 21:51:26 -0400
Message-ID: <4871769E.2020305@garzik.org>
References: <48714BA3.3080102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	john.ronciak@intel.com, ionut@cs.columbia.edu,
	baum@tehutinetworks.net, andy@greyhouse.net
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37048 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbYGGBvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 21:51:33 -0400
In-Reply-To: <48714BA3.3080102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> These patches fix all drivers supporting VLAN header stripping to
> pass the complete VLAN TCI to vlan_hwaccel_{rx,receive_skb} instead
> of just the VID. The upper three bits contain the priority and are
> used for ingress priority mappings.
> 
> The e1000 patch is runtime tested, the others only compile tested.
> 
> 
> drivers/net/e1000/e1000_main.c |   12 ++++--------
> drivers/net/e1000e/netdev.c    |    3 +--
> drivers/net/igb/igb_main.c     |    3 +--
> drivers/net/ixgb/ixgb_main.c   |    6 ++----
> drivers/net/starfire.c         |    2 +-
> drivers/net/tehuti.c           |    2 +-
> drivers/net/tehuti.h           |    1 +
> 7 files changed, 11 insertions(+), 18 deletions(-)
> 
> Patrick McHardy (6):
>      e1000: don't truncate VLAN TCI with VLAN stripping
>      e1000e: don't truncate VLAN TCI with VLAN stripping
>      igb: don't truncate VLAN TCI with VLAN stripping
>      ixgb: don't truncate VLAN TCI with VLAN stripping
>      starfire: don't truncate VLAN TCI with VLAN stripping
>      tehuti: don't truncate VLAN TCI with VLAN stripping

Acked-by: Jeff Garzik <jgarzik@redhat.com>

Though I would suggest combining all these patches into a single patch, 
since they constitute a single logical change, and each change is 
self-contained and small.

	Jeff



