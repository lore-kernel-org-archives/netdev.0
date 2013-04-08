From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 1/2] af_iucv: fix recvmsg by replacing skb_pull()
 function
Date: Mon, 08 Apr 2013 13:16:32 -0700
Message-ID: <1365452192.3887.39.camel@edumazet-glaptop>
References: <20130408081925.995757091@de.ibm.com>
	 <20130408082003.666955316@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, Ursula Braun <ursula.braun@de.ibm.com>
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f181.google.com ([209.85.210.181]:36970 "EHLO
	mail-ia0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935904Ab3DHUQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:16:38 -0400
In-Reply-To: <20130408082003.666955316@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 10:19 +0200, frank.blaschka@de.ibm.com wrote:
> plain text document attachment (601-af-iucv-skb-pull.diff)
> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> When receiving data messages, the "BUG_ON(skb->len < skb->data_len)" in
> the skb_pull() function triggers a kernel panic.
> 
> Replace the skb_pull logic by a per skb offset as advised by
> Eric Dumazet.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
> Reviewed-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
> ---

This is indeed a nicer patch ;)

Acked-by: Eric Dumazet <edumazet@google.com>
