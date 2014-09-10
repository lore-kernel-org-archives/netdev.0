From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: enable GRO for IPIP and SIT
Date: Tue, 09 Sep 2014 20:27:38 -0700 (PDT)
Message-ID: <20140909.202738.854167452821989542.davem@davemloft.net>
References: <1410286996-302-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaIJD1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 23:27:39 -0400
In-Reply-To: <1410286996-302-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue,  9 Sep 2014 11:23:13 -0700

> This patch sets populates the IPIP and SIT offload structures with
> gro_receive and gro_complete functions. This enables use of GRO
> for these. Also, fixed a problem in IPv6 where we were not properly
> initializing flush_id.

We're going to need to sort this out, because these functions are
now static after Eric's patches to fix sparse warnings.

You're going to have to respin this with that patch you intended
to add from the previous series that exported these routines.
