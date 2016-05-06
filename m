From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: vrf: Create FIB tables on link create
Date: Fri, 06 May 2016 15:52:11 -0400 (EDT)
Message-ID: <20160506.155211.622224584415415289.davem@davemloft.net>
References: <1462423572-15722-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758601AbcEFTwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 15:52:12 -0400
In-Reply-To: <1462423572-15722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  4 May 2016 21:46:12 -0700

> Tables have to exist for VRFs to function. Ensure they exist
> when VRF device is created.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - create table before rt6 allocation per comment from DaveM

Yep, this looks better, applied.
