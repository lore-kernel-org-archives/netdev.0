From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2014-01-14
Date: Mon, 13 Jan 2014 23:14:57 -0800 (PST)
Message-ID: <20140113.231457.1269719541362689128.davem@davemloft.net>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbaANHPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 02:15:00 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 14 Jan 2014 07:49:04 +0100

> This pull request has a merge conflict between commits be7928d20bab
> ("net: xfrm: xfrm_policy: fix inline not at beginning of declaration") and
> da7c224b1baa ("net: xfrm: xfrm_policy: silence compiler warning") from
> the net-next tree and commit 2f3ea9a95c58 ("xfrm: checkpatch erros with
> inline keyword position") from the ipsec-next tree.
> 
> The version from net-next can be used, like it is done in linux-next.
> 
> 1) Checkpatch cleanups, from Weilong Chen.
> 
> 2) Fix lockdep complaints when pktgen is used with IPsec,
>    from Fan Du.
> 
> 3) Update pktgen to allow any combination of IPsec transport/tunnel mode
>    and AH/ESP/IPcomp type, from Fan Du.
> 
> 4) Make pktgen_dst_metrics static, Fengguang Wu.
> 
> 5) Compile fix for pktgen when CONFIG_XFRM is not set,
>    from Fan Du.
> 
> Please pull or let me know if there are problems.

Pulled, thanks for the heads up about the merge conflicts.
