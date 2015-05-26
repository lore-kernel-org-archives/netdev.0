From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix inet_proto_csum_replace4() sparse
 errors
Date: Mon, 25 May 2015 22:56:34 -0400 (EDT)
Message-ID: <20150525.225634.2085109879500560586.davem@davemloft.net>
References: <1432605001.4060.215.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christophe.leroy@c-s.fr
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbbEZC4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 22:56:35 -0400
In-Reply-To: <1432605001.4060.215.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 May 2015 18:50:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/core/utils.o
 ...
> Note we can use csum_replace4() helper
> 
> Fixes: 58e3cac5613aa ("net: optimise inet_proto_csum_replace4()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Also applied, thanks Eric.
