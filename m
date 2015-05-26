From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove a sparse error in
 secure_dccpv6_sequence_number()
Date: Mon, 25 May 2015 22:56:17 -0400 (EDT)
Message-ID: <20150525.225617.210724936636952750.davem@davemloft.net>
References: <1432605348.4060.218.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbbEZC4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 22:56:21 -0400
In-Reply-To: <1432605348.4060.218.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 May 2015 18:55:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> make C=2 CF=-D__CHECK_ENDIAN__ net/core/secure_seq.o
> net/core/secure_seq.c:157:50: warning: restricted __be32 degrades to
> integer
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
