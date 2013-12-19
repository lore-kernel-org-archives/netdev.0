From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net v2 0/8] Fixes for server entries and server filter
 entries for Chelsio T4/T5
Date: Thu, 19 Dec 2013 15:37:54 +0530
Message-ID: <20131219100753.GA16770@hariprasad-pc>
References: <1387364906-1967-1-git-send-email-hariprasad@chelsio.com>
 <20131218141647.0b0cf403@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<roland@purestorage.com>, <dm@chelsio.com>,
	<swise@opengridcomputing.com>, <leedom@chelsio.com>,
	<santosh@chelsio.com>, <kumaras@chelsio.com>,
	<nirranjan@chelsio.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23235 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462Ab3LSKO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 05:14:29 -0500
Content-Disposition: inline
In-Reply-To: <20131218141647.0b0cf403@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 14:16:47 -0800, Stephen Hemminger wrote:
> While running namespace checks I found several this:
> 
> Subject: cxgb4: make functions static and remove dead code
> 
> Cleanup by making local functions static.
> 
> The code to load config file is unreachable in net-next, probably came
> from some out of tree driver.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
>
[...]

Hi Stephen,

Thank you for providing the fix. This reported namespace bug seems to be related
to existing code and not related to this patch series.

However, we now found another namespace bug in this patch series. So we will
respin this series with namespace fix.


Hi David,

Would you like to take this patch from Stephen separately, since it is not related
to this patch-series ?
Or should we include it as part of patch-series when we re-spin it as V3 ?


Thanks,
Hari.
