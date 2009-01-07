From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Wed, 7 Jan 2009 15:17:32 +1100
Message-ID: <20090107041732.GA22041@gondor.apana.org.au>
References: <bug-12327-10286@http.bugzilla.kernel.org/> <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com> <20090102083402.GA24383@gondor.apana.org.au> <4961ECD2.1000502@haveacry.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Speedster <speedster@haveacry.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55076 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756958AbZAGERn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 23:17:43 -0500
Content-Disposition: inline
In-Reply-To: <4961ECD2.1000502@haveacry.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2009 at 08:19:46PM +0900, Speedster wrote:
>
> I have tried both virtio and the default (8139too). The original dumps  
> were taken on whinge, I have attached two new dumps showing the  
> functional (2.6.24) and non-functional (2.6.27) states from the host.

The MAC on the PPPoE packets appears bogus:

22:07:58.344027 00:16:3e:24:f7:a1 > 00:18:18:54:19:54

Can you also attach a dump for connections that do work under
2.6.27? That should tell us whether this MAC is genuine.

If it is bogus, can you dump on the other interfaces to see
who is corrupting it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
