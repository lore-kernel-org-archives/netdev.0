From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vrf: Fix NAT within a VRF
Date: Sat, 17 Dec 2016 10:46:28 -0500 (EST)
Message-ID: <20161217.104628.972805183278675422.davem@davemloft.net>
References: <1481742378-28165-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754060AbcLQPq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:46:29 -0500
In-Reply-To: <1481742378-28165-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 14 Dec 2016 11:06:18 -0800

> Connection tracking with VRF is broken because the pass through the VRF
> device drops the connection tracking info. Removing the call to nf_reset
> allows DNAT and MASQUERADE to work across interfaces within a VRF.
> 
> Fixes: 73e20b761acf ("net: vrf: Add support for PREROUTING rules on vrf device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks David.
