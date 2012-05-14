From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 20:35:26 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1205142032570.28548@blackhole.kfki.hu>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com> <201205141809.18174.hans.schillstrom@ericsson.com> <1337012674.8512.589.camel@edumazet-glaptop> <201205141951.36692.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-in.kfki.hu ([148.6.0.26]:54452 "EHLO smtp1.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503Ab2ENSf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 14:35:29 -0400
In-Reply-To: <201205141951.36692.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 May 2012, Hans Schillstrom wrote:

> On Monday 14 May 2012 18:24:34 Eric Dumazet wrote:
> > On Mon, 2012-05-14 at 18:09 +0200, Hans Schillstrom wrote:
> > 
> > > This context can contain both le & be machines,
> > > so at least in hmark it make sense
> > 
> > Before jhash() and its shuffle ? What do you mean ?
> 
> I want that a Big endian machine should produce the same
> hash value independent of flow direction as a Little endian.
> 
> OK, I missed ntohl() before calling jhash_3words()
> 
> Correct me if I'm wrong here (have no big endian machine available for test)
> jhash_3words() and __jhash_final() seems to be "endian" safe.

No, but as Eric wrote: what is the point in forcing the same hash value 
for the same input on big endian and little endian machines? Are you going 
to transfer the hash value between machines?

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
