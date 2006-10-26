From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix integer overflow in H-TCP congestion control
Date: Wed, 25 Oct 2006 23:06:15 -0700 (PDT)
Message-ID: <20061025.230615.92585270.davem@davemloft.net>
References: <20061024141739.GB18364@nuim.ie>
	<20061024.153023.131917915.davem@davemloft.net>
	<20061025084726.GE18364@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, doug.leith@nuim.ie, baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26026
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423432AbWJZGGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 02:06:19 -0400
To: gavin.mccullagh@nuim.ie
In-Reply-To: <20061025084726.GE18364@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Date: Wed, 25 Oct 2006 09:47:26 +0100

> When using H-TCP with a single flow on a 500Mbit connection (or less
> actually), alpha can exceed 65000, so alpha needs to be a u32.
> 
> Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie>
> Signed-off-by: Doug Leith <doug.leith@nuim.ie>

Applied, thank you.
