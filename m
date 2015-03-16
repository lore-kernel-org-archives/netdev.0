From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2015-03-16
Date: Mon, 16 Mar 2015 16:17:09 -0400 (EDT)
Message-ID: <20150316.161709.445020712639772193.davem@davemloft.net>
References: <1426488744-17104-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbbCPURM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:17:12 -0400
In-Reply-To: <1426488744-17104-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 16 Mar 2015 07:52:21 +0100

> 1) Fix the network header offset in _decode_session6
>    when multiple IPv6 extension headers are present.
>    From Hajime Tazaki.
> 
> 2) Fix an interfamily tunnel crash. We set outer mode
>    protocol too early and may dispatch to the wrong
>    address family. Move the setting of the outer mode
>    protocol behind the last accessing of the inner mode
>    to fix the crash.
> 
> 3) Most callers of xfrm_lookup() expect that dst_orig
>    is released on error. But xfrm_lookup_route() may
>    need dst_orig to handle certain error cases. So
>    introduce a flag that tells what should be done in
>    case of error. From Huaibin Wang.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot.
