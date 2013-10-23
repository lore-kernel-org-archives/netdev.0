From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-10-23
Date: Wed, 23 Oct 2013 17:13:03 -0400 (EDT)
Message-ID: <20131023.171303.896342188641327344.davem@davemloft.net>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab3JWVNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 17:13:05 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed, 23 Oct 2013 18:04:47 +0200

> this is another set of changes intended for net-next/linux-3.13.
> (probably our last pull request for this cycle)
> 
> Patches 1 and 2 reshape two of our main data structures in a way that they can
> easily be extended in the future to accommodate new routing protocols.
> 
> Patches from 3 to 9 improve our routing protocol API and its users so that all
> the protocol-related code is not mixed up with the other components anymore.
> 
> Patch 10 limits the local Translation Table maximum size to a value such that it
> can be fully transfered over the air if needed. This value depends on
> fragmentation being enabled or not and on the mtu values.
> 
> Patch 11 makes batman-adv send a uevent in case of soft-interface destruction
> while a "bat-Gateway" was configured (this informs userspace about the GW not
> being available anymore).
> 
> Patches 13 and 14 enable the TT component to detect non-mesh client flag
> changes at runtime (till now those flags where set upon client detection and
> were not changed anymore).
> 
> Patch 16 is a generalisation of our user-to-kernel space communication (and
> viceversa) used to exchange ICMP packets to send/received to/from the mesh
> network. Now it can easily accommodate new ICMP packet types without breaking
> the existing userspace API anymore.
> 
> Remaining patches are minor changes and cleanups.

Pulled, thanks Antonio.
