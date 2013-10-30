From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Tue, 29 Oct 2013 21:03:05 -0700
Message-ID: <1383105785.4857.21.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028115552.GC4408@cpaasch-mac>
	 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029144100.GA28046@gondor.apana.org.au>
	 <1383059293.5464.31.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131030015002.GB1347@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45039 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab3J3EDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:03:11 -0400
Received: by mail-pa0-f46.google.com with SMTP id rd3so333144pab.33
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 21:03:10 -0700 (PDT)
In-Reply-To: <20131030015002.GB1347@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 09:50 +0800, Herbert Xu wrote:
> On Tue, Oct 29, 2013 at 08:08:13AM -0700, Eric Dumazet wrote:
> >
> > GRO layer was updated to be able to stack two or three sk_buff,
> > fully populated with page frags.
> > 
> > Thats quite mandatory to support line rate for 40Gb links.
> 
> Indeed I missed this.  Which commit introduced this change?

This was mentioned in the changelog :

<quote>

Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")

</quote>
