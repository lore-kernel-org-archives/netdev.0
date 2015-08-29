From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: Do not try to search for the transport twice
Date: Fri, 28 Aug 2015 22:26:53 -0700 (PDT)
Message-ID: <20150828.222653.1927768559958135366.davem@davemloft.net>
References: <1440811419-12793-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbbH2F0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:26:54 -0400
In-Reply-To: <1440811419-12793-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Fri, 28 Aug 2015 21:23:39 -0400

> When removing an non-primary transport during ASCONF
> processing, we end up traversing the transport list
> twice: once in sctp_cmd_del_non_primary, and once in
> sctp_assoc_del_peer.  We can avoid the second
> search and call sctp_assoc_rm_peer() instead.
> Found by code inspection during code reviews.
> 
> Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>

Applied.
