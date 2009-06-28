From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Sun, 28 Jun 2009 14:03:28 +0200
Message-ID: <20090628120328.GA2739@ami.dom.local>
References: <19012.37515.146191.198843@robur.slu.se> <20090627192057.GA5041@ami.dom.local> <19015.20051.432572.460207@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, "Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:34242 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbZF1MDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 08:03:37 -0400
Received: by bwz9 with SMTP id 9so2776655bwz.37
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2009 05:03:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <19015.20051.432572.460207@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 28, 2009 at 01:04:51PM +0200, Robert Olsson wrote:
...
>  Yes we keep the old tnode size and the convergence interval was some
>  of the concerns. That why this checks was added. Still we want to
>  inflate the root node to a very max. 
> 
>  So this approach with halving or doubling tnodes towards the root
>  node was the suggest by Dyntree paper. I asked Stefan (one of the
>  authors) if we could get safe and very offensive settings. But 
>  from what I understood there was no easy way to calculate this. 
>  So any bright ideas in this area are very welcome. But we should
>  also monitor size of root and average tree depth so we don't
>  take an to defensive approach just to solve this case.

Yes, but with this offensive approach it seems the current level of
warnings could be too alarming. Btw., because of a design flaw in my
current patch this _fix variable, which should be logically per trie/
table, can be reset by changes of other tables now, but I think it
all could be fine tuned more in the future. Of course if there are
people interested in testing/reporting this more.

Thanks,
Jarek P.
