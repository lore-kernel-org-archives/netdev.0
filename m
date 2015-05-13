From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: __ip_local_out_sk() is static
Date: Wed, 13 May 2015 15:22:02 -0400 (EDT)
Message-ID: <20150513.152202.1071666364872453232.davem@davemloft.net>
References: <1431437508.566.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbbEMTWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:22:04 -0400
In-Reply-To: <1431437508.566.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 May 2015 06:31:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> __ip_local_out_sk() is only used from net/ipv4/ip_output.c
> 
> net/ipv4/ip_output.c:94:5: warning: symbol '__ip_local_out_sk' was not
> declared. Should it be static?
> 
> Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
