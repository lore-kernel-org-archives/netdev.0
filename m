From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: [PATCH net-next] Revert "cxgb4: Don't assume LSO only uses SGL
 path in t4_eth_xmit()"
Date: Thu, 6 Mar 2014 20:51:42 +0600
Message-ID: <20140306145141.GF29631@kumar-pc.asicdesigners.com>
References: <1394016556-12358-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<santosh@chelsio.com>, <nirranjan@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25063 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750828AbaCFPUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 10:20:30 -0500
Content-Disposition: inline
In-Reply-To: <1394016556-12358-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wednesday, March 03/05/14, 2014 at 16:19:16 +0530, Hariprasad Shenai wrote:
> Commit 0034b29 (cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit())
> introduced a regression causing chip-hang. This patch needs more debugging and
> more work. So reverting for now.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
[...]
> 

I was finally able to root-cause issue, and have prepared a proper fix.
Turns out, the len calculation was not done properly. So, this revert patch is 
now no longer required.

If this revert patch is not yet merged in net-next, and if its OK with you then,
could you please drop this revert patch from your patch-queue ?
I will get the proper fix submitted for this regression.

Sorry for the trouble caused by this LSO related patch.

Thanks,
Kumar.
