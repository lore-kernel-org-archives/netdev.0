From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: Use kcalloc/kmalloc_array to allocate
 arrays
Date: Wed, 25 Jun 2014 16:40:18 -0700 (PDT)
Message-ID: <20140625.164018.1869634626144024561.davem@davemloft.net>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
	<1403616802-25743-3-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, ast@plumgrid.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341AbaFYXkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:40:18 -0400
In-Reply-To: <1403616802-25743-3-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 24 Jun 2014 15:33:22 +0200

> Use kcalloc/kmalloc_array to make it clear we're allocating arrays. No
> integer overflow can actually happen here, since len/flen is guaranteed
> to be less than BPF_MAXINSNS (4096). However, this changed makes sure
> we're not going to get one if BPF_MAXINSNS were ever increased.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thank you.
