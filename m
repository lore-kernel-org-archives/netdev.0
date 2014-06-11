From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] net: add __pskb_copy_fclone and
 pskb_copy_for_clone
Date: Wed, 11 Jun 2014 15:38:23 -0700 (PDT)
Message-ID: <20140611.153823.1721612284882638761.davem@davemloft.net>
References: <1402526186-18619-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoph.paasch@uclouvain.be,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	antonio@meshcoding.com, marcel@holtmann.org, gustavo@padovan.org,
	johan.hedberg@gmail.com, arvid.brodin@alten.se, kaber@trash.net,
	pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, andrew.hendry@gmail.com,
	edumazet@google.com
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbaFKWiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:38:24 -0400
In-Reply-To: <1402526186-18619-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Thu, 12 Jun 2014 01:36:26 +0300

> There are several instances where a pskb_copy or __pskb_copy is
> immediately followed by an skb_clone.
> 
> Add a couple of new functions to allow the copy skb to be allocated
> from the fclone cache and thus speed up subsequent skb_clone calls.
 ...
> Reviewed-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
> ---
> 
> Changes since v4:
>  * Oops, as Dave noticed, there is no need to rewrite pskb_copy()
> 
> Changes since v3:
>  * As suggested by David and Dave add new functions to keep the
>    existing signatures unchanged and avoid unnecessary changes  
> 
> Changes since v2:
>  * As suggested by Dave, use a bool instead of directly exposing the
>    internal allocation flags
> 
> Changes since v1:
>  * add new parameter to pskb_copy as well, as suggested by Christoph

Applied to net-next, thanks a lot.
