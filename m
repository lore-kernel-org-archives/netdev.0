From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Don't propagate flag changes on down interfaces.
Date: Tue, 01 Nov 2011 17:51:13 -0400 (EDT)
Message-ID: <20111101.175113.2141024983069963090.davem@davemloft.net>
References: <20111031134411.GG14392@login.drsnuggles.stderr.nl>
	<1320072793-16490-1-git-send-email-matthijs@stdin.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matthijs@stdin.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565Ab1KAVvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 17:51:20 -0400
In-Reply-To: <1320072793-16490-1-git-send-email-matthijs@stdin.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthijs Kooijman <matthijs@stdin.nl>
Date: Mon, 31 Oct 2011 15:53:13 +0100

> When (de)configuring a vlan interface, the IFF_ALLMULTI ans IFF_PROMISC
> flags are cleared or set on the underlying interface. So, if these flags
> are changed on a vlan interface that is not up, the flags underlying
> interface might be set or cleared twice.
> 
> Only propagating flag changes when a device is up makes sure this does
> not happen. It also makes sure that an underlying device is not set to
> promiscuous or allmulti mode for a vlan device that is down.
> 
> Signed-off-by: Matthijs Kooijman <matthijs@stdin.nl>

Applied, thanks.
