From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Tue, 29 Oct 2013 21:15:51 -0700
Message-ID: <CAPshTCiFvPL3fFymr6Sm6gz3LjpHuh71XjZxuxstjdNhW3bnxA@mail.gmail.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029.194446.2215574000648693370.davem@davemloft.net>
	<1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029.220253.1263087684709722001.davem@davemloft.net>
	<1383106012.4857.26.camel@edumazet-glaptop.roam.corp.google.com>
	<20131030040818.GB2755@gondor.apana.org.au>
	<20131030040949.GA2912@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Dalton <mwdalton@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f54.google.com ([209.85.212.54]:37532 "EHLO
	mail-vb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab3J3EPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:15:53 -0400
Received: by mail-vb0-f54.google.com with SMTP id q12so544176vbe.13
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 21:15:52 -0700 (PDT)
In-Reply-To: <20131030040949.GA2912@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 9:09 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Oct 30, 2013 at 12:08:18PM +0800, Herbert Xu wrote:
>> On Tue, Oct 29, 2013 at 09:06:52PM -0700, Eric Dumazet wrote:
>> >
>> > I am not sure 64K GRO packets that must be segmented are going to be
>> > faster than 22K packets without segmentation at all (TSO path on xmit)
>>
>> Indeed that is a tough call, but I think conceptually the 64K
>> case is much nicer than a sysctl that gets magically turned off.
>
> Also at some point we'll want to do >64K GRO/GSO too so we'll
> have to face this complexity one day.

Not sure how this is possible with the IP datagram length limit. (Am I
missing something, like pkt chaining?)

Jerry

>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
