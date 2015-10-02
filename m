From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bridge: vlan: cleanups & fixes
Date: Thu, 01 Oct 2015 18:07:29 -0700 (PDT)
Message-ID: <20151001.180729.1453077933138144189.davem@davemloft.net>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	vyasevich@gmail.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbbJBAwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 20:52:05 -0400
In-Reply-To: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed, 30 Sep 2015 20:16:50 +0200

> This is the first follow-up set, patch 01 reduces the default rhashtable
> size and the number of locks that can be allocated. Patch 02 and 04 fix
> possible null pointer dereferences due to the new ordering and
> initialization on port add/del, and patch 03 moves the "pvid" member in
> the net_bridge_vlan_group struct in order to simplify code (similar to how
> it was with the older struct). Patch 05 fixes adding a vlan on a port which
> is pvid and doesn't have a global context yet.
> Please review carefully, I think this is the first use of rhashtable's
> "locks_mul" member in the tree and I'd like to make sure it's correct.
> Another thing that needs special attention is the nbp_vlan_flush() move
> after the rx_handler unregister.

Series applied, thanks.
