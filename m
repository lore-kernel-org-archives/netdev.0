From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 21:44:54 +1000
Message-ID: <20090427114454.GB15891@kryten>
References: <49F53FF6.2040603@cosmosbay.com> <20090427054702.GA15891@kryten> <49F54CC5.7020600@cosmosbay.com> <20090426.233638.83897914.davem@davemloft.net> <49F5550A.1050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57338 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175AbZD0LqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 07:46:11 -0400
Content-Disposition: inline
In-Reply-To: <49F5550A.1050805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Yes, as setups needing more than 512.000 slots (and 2 million entries with an
> average of 4 entries per slot) are certainly able to boot with an override.
> 
> Anton, please resubmit with this 512 k limit, and my :
> 
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks Eric, I'll respin with the limit set at 512k.

Anton
