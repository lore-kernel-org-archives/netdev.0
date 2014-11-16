From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Sun, 16 Nov 2014 10:22:27 +0800
Message-ID: <20141116022227.GA24541@gondor.apana.org.au>
References: <20141115191219.GA19060@thin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:55524 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbaKPCXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 21:23:15 -0500
Content-Disposition: inline
In-Reply-To: <20141115191219.GA19060@thin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Triplett <josh@joshtriplett.org> wrote:
>
> - Set up the new empty table with the new set of hash parameters.
> - synchronize_rcu().  Readers will now search both old and new tables.
> - Peel nodes off the ends of the old hash table and add them to the new

We currently use a singly linked list in rhashtable.  Peeling nodes
off the end would mean upgrading to a doubly linked list, which is
no different than keeping two lists in terms of cache footprint, no?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
