From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vrf: plug skb leaks
Date: Thu, 20 Aug 2015 12:59:57 -0700 (PDT)
Message-ID: <20150820.125957.1954269422093054346.davem@davemloft.net>
References: <1439953949-23736-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbbHTUAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:00:00 -0400
In-Reply-To: <1439953949-23736-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed, 19 Aug 2015 06:12:29 +0300

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Currently whenever a packet different from ETH_P_IP is sent through the
> VRF device it is leaked so plug the leaks and properly drop these
> packets.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
