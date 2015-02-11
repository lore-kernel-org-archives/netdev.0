From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv6: Partial checksum only UDP packets
Date: Wed, 11 Feb 2015 14:32:53 -0800 (PST)
Message-ID: <20150211.143253.1012085447903167405.davem@davemloft.net>
References: <1423586249-5950-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbbBKWZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 17:25:52 -0500
In-Reply-To: <1423586249-5950-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 10 Feb 2015 11:37:29 -0500

> ip6_append_data is used by other protocols and some of them can't
> be partially checksummed.  Only partially checksum UDP protocol.
> 
> Fixes: 32dce968dd987a (ipv6: Allow for partial checksums on non-ufo packets)
> Reported-by: Sabrina Dubroca <sd@queasysnail.net>
> Tested-by: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
> v2:  added tested-by tag and fixed compile issue with prior patch.

Applied, thanks.
