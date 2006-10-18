From: Rick Jones <rick.jones2@hp.com>
Subject: Re: BCM5461 phy issue in 10M/Full duplex
Date: Wed, 18 Oct 2006 09:53:57 -0700
Message-ID: <45365C25.9070601@hp.com>
References: <BD5AE82A-22F1-4813-A350-42532AB9A920@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:55719 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1422684AbWJRQx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 12:53:59 -0400
To: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <BD5AE82A-22F1-4813-A350-42532AB9A920@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> I was wondering if anyone has had any issues when trying to force a  
> BCM5461 phy into 10M/full duplex.  I seem to be having an issue in  the 
> two managed switches I've tried this on but autoneg to 10/half.   This 
> causes a problem in that I start seeing a large number of frame  errors.
> 
> I believe, but need to double check, that if I leave the BCM5461 in  
> autoneg, and foce the switch to 10M/full that the BCM5461 will  autoneg 
> at 10M/half duplex.

Indeed, if one side is hardcoded, autoneg will "fail" and the side trying to 
autoneg is required by the specs (not that I know chapter and verse to quote 
from the IEE stuff :( to go into half-duplex.

Was 10M/Fullduplex ever standardized?  If not I could see where kit might not be 
willing/able to autoneg to that.

> Just wondering if anyone else has seen similar behavior with this PHY.
> 
> thanks
> 
> - kumar
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

