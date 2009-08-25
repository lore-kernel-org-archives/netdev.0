From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bridge] VLANs and bridge
Date: Tue, 25 Aug 2009 16:00:44 +0200
Message-ID: <4A93EE8C.6040008@trash.net>
References: <OFC5BA9A4A.DCCE8D0D-ONC125761A.004A7620-C125761A.004BEA17@transmode.se> <4A9001E3.6060506@superduper.net> <OF2C06F138.1BC279AE-ONC125761A.0054117B-C125761A.0055C6F1@LocalDomain> <OF9BD07CB5.A2197AEA-ONC125761A.005AE004-C125761A.005B662E@transmode.se> <4A9026EA.9020404@superduper.net> <OF7400A5E8.F4AC001F-ONC125761C.00674A25-C125761C.00679758@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@superduper.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46840 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbZHYOAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 10:00:45 -0400
In-Reply-To: <OF7400A5E8.F4AC001F-ONC125761C.00674A25-C125761C.00679758@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Simon Barber <simon@superduper.net> wrote on 22/08/2009 19:12:10:
>> Looking through B.1.3 it looks like the patch would need some
>> enhancement. It provides a good basis - handling tagging/untagging and
>> filtering, but would need a way to specify the untagged vlan separately
>> for in and out.
> 
> I see. Perhaps the VLAN maintainer(CC:ed) can comment too. Especially about extending
> the VLAN code to allowed several VLANs in one interface?

Just accepting additional VIDs on one VLAN device should be
a relatively trivial change, all you need to do is call
vlan_group_set_device() with the additional VIDs.

I'd suggest to add something similar to the QoS-mapping lists
in vlan_netlink.c for the additional VIDs.




