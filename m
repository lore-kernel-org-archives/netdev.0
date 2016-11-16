From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix rtnl message size computation for
 XDP
Date: Tue, 15 Nov 2016 22:43:01 -0500 (EST)
Message-ID: <20161115.224301.179517453653413520.davem@davemloft.net>
References: <0169d2419991a4ba533087a4fda70420ccdaca30.1479204870.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932211AbcKPDnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:43:03 -0500
In-Reply-To: <0169d2419991a4ba533087a4fda70420ccdaca30.1479204870.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 15 Nov 2016 11:16:35 +0100

> rtnl_xdp_size() only considers the size of the actual payload attribute,
> and misses the space taken by the attribute used for nesting (IFLA_XDP).
> 
> Fixes: d1fdd9138682 ("rtnl: add option for setting link xdp prog")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable.
