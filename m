From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12743] New: Oops when renaming interfaces
	added to a bridge
Date: Sat, 21 Feb 2009 21:06:13 +0800
Message-ID: <20090221130612.GA28711@gondor.apana.org.au>
References: <20090220094519.d8ad0496.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	shemminger@linux-foundation.org,
	enrico.scholz@informatik.tu-chemnitz.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33815 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752902AbZBUNGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 08:06:20 -0500
Content-Disposition: inline
In-Reply-To: <20090220094519.d8ad0496.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> When renaming an interface which was added to a bridge, its name won't
>> be changed in the bridge setup.  Adding another interface which was
>> created later with the original name,  kernel oopses

Looks like we screwed up when designing the sysfs interface.
The port name really shouldn't show up at all as a file name.

Now we'll have to either add a nasty hack to locate all these
sysfs objects and rename them, or figure out a way to phase this
out.

I really hate sysfs!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
