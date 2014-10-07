From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: allow transmit tagged frames
Date: Tue, 07 Oct 2014 00:02:00 -0400 (EDT)
Message-ID: <20141007.000200.1161558430661614993.davem@davemloft.net>
References: <1412614957-18549-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaJGECC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:02:02 -0400
In-Reply-To: <1412614957-18549-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Mon,  6 Oct 2014 19:02:37 +0200

> When Tx VLAN offloading is disabled frames with size ~ MTU are not
> transmitted as the driver does not account 4 bytes of VLAN header added
> by stack. It should use VLAN_ETH_HLEN instead of ETH_HLEN.
> 
> The second problem is with newer BNA chips (BNA 1860). These chips filter
> out any VLAN tagged frames in Tx path. This is a problem when Tx VLAN
> offloading is disabled and frames are tagged by stack. Older chips like
> 1010/1020 are not affected as they probably don't do such filtering.
> 
> Cc: Rasesh Mody <rasesh.mody@qlogic.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
