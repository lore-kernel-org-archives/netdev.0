From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm: removes a superfluous check and add a
 statistic
Date: Fri, 28 Dec 2012 15:22:35 -0800 (PST)
Message-ID: <20121228.152235.290256503144308680.davem@davemloft.net>
References: <1356681988-7985-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855Ab2L1XWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 18:22:36 -0500
In-Reply-To: <1356681988-7985-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 28 Dec 2012 16:06:28 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Remove the check if x->km.state equal to XFRM_STATE_VALID in
> xfrm_state_check_expire(), which will be done before call
> xfrm_state_check_expire().
> 
> add a LINUX_MIB_XFRMOUTSTATEINVALID statistic to record the
> outbound error due to invalid xfrm state.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

I'll let Steffen pick this up when he returns from his holiday
break.

Please CC: him on all IPSEC changes since he is the primary
IPSEC maintainer and is the one who will integrate your IPSEC
patches into his ipsec GIT tree.
