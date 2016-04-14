From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/5] qed/qede: Add VXLAN tunnel slowpath
 configuration support
Date: Thu, 14 Apr 2016 16:15:04 -0400 (EDT)
Message-ID: <20160414.161504.381200373149512245.davem@davemloft.net>
References: <1460612313-20323-3-git-send-email-manish.chopra@qlogic.com>
	<20160414.152601.1422370571524886675.davem@davemloft.net>
	<SN2PR11MB0094C4E2F13DA03C1E06C99497970@SN2PR11MB0094.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, netdev@vger.kernel.org,
	Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbcDNUPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 16:15:09 -0400
In-Reply-To: <SN2PR11MB0094C4E2F13DA03C1E06C99497970@SN2PR11MB0094.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 14 Apr 2016 19:52:44 +0000

>> Why do you call all of these offloads the "slowpath"?
> 
> We term by 'slowpath' all the non {data,fast}path configurations,
> I.e., everything that doesn't really involves the ingress/egress handling
> of packets but rather the infrastructure changes surrounding it.
> 
> That exactly what we have in this patch - adding the ndo hooks
> necessary for configuring the FW/HW in the proper mode to support
> vxlan tunnels.
> 
> Only the last patch in the series is actually adding the fastpath stuff.

Thanks for explaining.
