From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: add API to retrieve all group memberships
Date: Mon, 15 Jun 2015 15:13:54 -0700 (PDT)
Message-ID: <20150615.151354.2277595107897040931.davem@davemloft.net>
References: <1434125738-1990-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org
To: dh.herrmann@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755914AbbFOWNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 18:13:55 -0400
In-Reply-To: <1434125738-1990-1-git-send-email-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Herrmann <dh.herrmann@gmail.com>
Date: Fri, 12 Jun 2015 18:15:38 +0200

> This patch adds getsockopt(SOL_NETLINK, NETLINK_LIST_MEMBERSHIPS) to
> retrieve all groups a socket is a member of. Currently, we have to use
> getsockname() and look at the nl.nl_groups bitmask. However, this mask is
> limited to 32 groups. Hence, similar to NETLINK_ADD_MEMBERSHIP and
> NETLINK_DROP_MEMBERSHIP, this adds a separate sockopt to manager higher
> groups IDs than 32.
> 
> This new NETLINK_LIST_MEMBERSHIPS option takes a pointer to __u32 and the
> size of the array. The array is filled with the full membership-set of the
> socket, and the required array size is returned in optlen. Hence,
> user-space can retry with a properly sized array in case it was too small.
> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

This does not apply to the current net-next tree, please respin.
