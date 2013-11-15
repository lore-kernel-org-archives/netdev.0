From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Thu, 14 Nov 2013 20:37:04 -0800
Message-ID: <1384490224.28716.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131107070647.GB31638@gondor.apana.org.au>
	 <20131111185207.GA12277@gondor.apana.org.au>
	 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113012920.GA27897@gondor.apana.org.au>
	 <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113022243.GA28204@gondor.apana.org.au>
	 <20131113022525.GA28236@gondor.apana.org.au>
	 <1384310704.28458.79.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131113142615.GA1851@gondor.apana.org.au>
	 <1384355185.28458.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131114081117.GA12708@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33832 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114Ab3KOEhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 23:37:07 -0500
Received: by mail-pa0-f42.google.com with SMTP id kx10so2320957pab.15
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 20:37:05 -0800 (PST)
In-Reply-To: <20131114081117.GA12708@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 16:11 +0800, Herbert Xu wrote:
> On Wed, Nov 13, 2013 at 07:06:25AM -0800, Eric Dumazet wrote:
> >
> > Well, I wont try this patch, as it can not possibly work :(
> 
> You're right.  It sort of worked for me because I had the GSO
> features test reversed meaning it never enabled my new code.
> 
> This new patch is still incomplete in that it only does TCPv4 but
> it does actually seem to work.
> 
> Please let me know what the performance numbers look like.

Just an update :  I 'lost' the host to do this experiment,
and will regain it shortly.
