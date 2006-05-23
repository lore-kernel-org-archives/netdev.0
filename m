From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: need to ref count the LLC sap
Date: Tue, 23 May 2006 15:21:03 -0700 (PDT)
Message-ID: <20060523.152103.97293770.davem@davemloft.net>
References: <20060523151035.43e7e4f6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13747
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750888AbWEWWVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 18:21:47 -0400
To: shemminger@osdl.org
In-Reply-To: <20060523151035.43e7e4f6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge: need to ref count the LLC sap
Date: Tue, 23 May 2006 15:10:35 -0700

> Bridge will OOPS on removal if other application has the SAP open.
> The bridge SAP might be shared with other usages, so need
> to do reference counting on module removal rather than explicit
> close/delete.
> 
> Since packet might arrive after or during removal, need to clear
> the receive function handle, so LLC only hands it to user (if any).
> 
> This should go in 2.616.stable and 2.6.17.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks a lot.

Please submit to -stable.
