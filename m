From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: [PATCH net-next] include/net/raw.h: Convert raw_seq_private
 macro to inline
Date: Tue, 7 Sep 2010 11:37:21 -0400
Message-ID: <20100907153721.GA6419@elliptictech.com>
References: <cover.1283650107.git.joe@perches.com>
 <dd5d79c3aa9f2cffbca1a8d4a9163b0d6a9492a9.1283650107.git.joe@perches.com>
 <20100906.183036.68150190.davem@davemloft.net>
 <20100906.184749.214227378.davem@davemloft.net>
 <1283835677.23280.108.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, trivial@kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.elliptictech.com ([209.217.122.41]:50562 "EHLO
	emergent.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757844Ab0IGPiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 11:38:09 -0400
Content-Disposition: inline
In-Reply-To: <1283835677.23280.108.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-06 22:01 -0700, Joe Perches wrote:
> diff --git a/include/net/raw.h b/include/net/raw.h
> index 43c5750..c621200 100644
> --- a/include/net/raw.h
> +++ b/include/net/raw.h
> @@ -45,7 +45,10 @@ struct raw_iter_state {
>  	struct raw_hashinfo *h;
>  };
>  
> -#define raw_seq_private(seq) ((struct raw_iter_state *)(seq)->private)
> +inline struct raw_iter_state *raw_seq_private(struct seq_file *seq)

This needs to be declared static.

> +{
> +	return seq->private;
> +}
>  void *raw_seq_start(struct seq_file *seq, loff_t *pos);
>  void *raw_seq_next(struct seq_file *seq, void *v, loff_t *pos);
>  void raw_seq_stop(struct seq_file *seq, void *v);

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
