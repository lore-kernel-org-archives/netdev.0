From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4] bonding: Do not try to send packets over dead link
 in TLB mode.
Date: Wed, 16 Jul 2014 23:35:46 -0700 (PDT)
Message-ID: <20140716.233546.310404043860448834.davem@davemloft.net>
References: <1405534236-26542-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, edumazet@google.com, maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaGQGfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:35:47 -0400
In-Reply-To: <1405534236-26542-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 16 Jul 2014 11:10:36 -0700

> In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
> group are selected based on the hash distribution. This does not
> exclude dead links which are part of the bond. Also if there is a
> temporary link event which brings down the interface, packets
> hashed on that interface would be dropped too.
> 
> This patch fixes these issues and distributes flows across the
> UP links only. Also the array construction of links which are
> capable of sending packets happen in the control path leaving
> only link-selection during the data-path.
> 
> One possible side effect of this is - at a link event; all
> flows will be shuffled to get good distribution. But impact of
> this should be minimum with the assumption that a member or
> members of the bond group are not available is a very temporary
> situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
