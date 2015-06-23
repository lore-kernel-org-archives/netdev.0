From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] switchdev; add VLAN support for port's
 bridge_getlink
Date: Tue, 23 Jun 2015 06:57:42 -0700 (PDT)
Message-ID: <20150623.065742.1232677044170674438.davem@davemloft.net>
References: <1434958037-26057-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
	ronen.arad@intel.com, f.fainelli@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585AbbFWNpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:45:53 -0400
In-Reply-To: <1434958037-26057-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Mon, 22 Jun 2015 00:27:15 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> One more missing piece of the puzzle.  Add vlan dump support to switchdev
> port's bridge_getlink.  iproute2 "bridge vlan show" cmd already knows how
> to show the vlans installed on the bridge and the device , but (until now)
> no one implemented the port vlan part of the netlink PF_BRIDGE:RTM_GETLINK
> msg.  Before this patch, "bridge vlan show":
 ...
> (When the port is bridged, the output repeats the vlan list for the vlans
> on the bridge side of the port and the vlans on the device side of the
> port.  The listing above show no vlans for the device side even though they
> are installed).
> 
> After this patch:
 ...

Series applied, thanks Scott.
