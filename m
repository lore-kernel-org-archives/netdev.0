From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] silence a warning in ebtables
Date: Wed, 01 Nov 2006 18:07:57 -0800 (PST)
Message-ID: <20061101.180757.94889727.davem@davemloft.net>
References: <Pine.SOC.4.61.0611011857340.11421@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31385
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751537AbWKBCHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 21:07:52 -0500
To: mroos@linux.ee
In-Reply-To: <Pine.SOC.4.61.0611011857340.11421@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Wed, 1 Nov 2006 19:01:14 +0200 (EET)

> net/bridge/netfilter/ebtables.c: In function 'ebt_dev_check':
> net/bridge/netfilter/ebtables.c:89: warning: initialization discards qualifiers from pointer target type
> 
> So make the char* a const char * and the warning is gone.
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

Applied, thanks a lot.
