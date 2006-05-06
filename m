From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [SCTP]: Allow spillover of receiver buffer to
 avoid deadlock
Date: Fri, 05 May 2006 17:02:53 -0700 (PDT)
Message-ID: <20060505.170253.02890631.davem@davemloft.net>
References: <1146856468.7861.33.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40141
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750745AbWEFADD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 20:03:03 -0400
To: sri@us.ibm.com
In-Reply-To: <1146856468.7861.33.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 05 May 2006 12:14:28 -0700

> [SCTP]: Allow spillover of receive buffer to avoid deadlock.
> 
> This patch fixes a deadlock situation in the receive path by allowing
> temporary spillover of the receive buffer.
> 
> - If the chunk we receive has a tsn that immediately follows the ctsn,
>   accept it even if we run out of receive buffer space and renege data with
>   higher TSNs.
> - Once we accept one chunk in a packet, accept all the remaining chunks
>   even if we run out of receive buffer space.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Mark Butler <butlerm@middle.net>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied with trailing whitespace removed.  Please double-check
all of your patches with something like:

	git apply --check --whitespace=error-all diff

before submission.

Thanks.
