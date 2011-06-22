From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ip: introduce ip_is_fragment helper inline
 function
Date: Tue, 21 Jun 2011 20:33:47 -0700 (PDT)
Message-ID: <20110621.203347.384207505903484883.davem@davemloft.net>
References: <1308680702-2212-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757564Ab1FVDdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 23:33:50 -0400
In-Reply-To: <1308680702-2212-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 21 Jun 2011 14:25:02 -0400

> There are enough instances of this:
> 
>     iph->frag_off & htons(IP_MF | IP_OFFSET)
> 
> that a helper function is probably warranted.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
