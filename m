From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vrf: remove slave queue and private slave
 struct
Date: Tue, 24 Nov 2015 16:26:58 -0500 (EST)
Message-ID: <20151124.162658.1414383178450357641.davem@davemloft.net>
References: <1448371756-32188-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbbKXV07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:26:59 -0500
In-Reply-To: <1448371756-32188-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 24 Nov 2015 14:29:16 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> The private slave queue and slave struct haven't been used for anything
> and aren't needed, this allows to reduce memory usage and simplify
> enslave/release. We can use netdev_for_each_lower_dev() to free the vrf
> ports when deleting a vrf device. Also if in the future a private struct
> is needed for each slave, it can be implemented via lower devices'
> private member (similar to how bonding does it).
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thank you.
