From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [Bridge] [PATCH] net/bridge/netfilter: Fix the randconfig warning
Date: Thu, 17 May 2012 09:21:41 +0200
Message-ID: <4FB4A705.6040906@pandora.be>
References: <1337023817-26132-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: Devendra Naga <devendra.aaru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juliette.telenet-ops.be ([195.130.137.74]:54094 "EHLO
	juliette.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761188Ab2EQHVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 03:21:48 -0400
In-Reply-To: <1337023817-26132-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Op 14/05/2012 21:30, Devendra Naga schreef:
> when ran with make randconfig got
>
> warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has unmet direct dependencies (NET&&  INET&&  NETFILTER)
>
> added NET&&  INET&&  NETFILTER dependency to the BRIDGE_NF_EBTABLES

I really don't see why ebtables should depend on INET. To me the issue 
lies in the fact that xtables depends on INET.

Bart

-- 
Bart De Schuymer
www.artinalgorithms.be
