From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2013-11-01
Date: Sat, 02 Nov 2013 01:22:56 -0400 (EDT)
Message-ID: <20131102.012256.1806070941734948930.davem@davemloft.net>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab3KBFW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 01:22:57 -0400
In-Reply-To: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri,  1 Nov 2013 09:21:44 +0100

> 1) Fix a possible race on ipcomp scratch buffers because
>    of too early enabled siftirqs. From Michal Kubecek.
> 
> 2) The current xfrm garbage collector threshold is too small
>    for some workloads, resulting in bad performance on these
>    workloads. Increase the threshold from 1024 to 32768.
> 
> 3) Some codepaths might not have a dst_entry attached to the
>    skb when calling xfrm_decode_session(). So add a check
>    to prevent a null pointer dereference in this case.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen!
