From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 00/10] Netfilter fixes for net
Date: Fri, 13 Nov 2015 19:52:58 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1511131951410.29408@blackhole.kfki.hu>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org> <CA+5PVA7bbnn+29+pc-JwXDUtNn36Eab0K7U1hOY09hf3T-7q1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-in.kfki.hu ([148.6.0.26]:57024 "EHLO smtp1.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754969AbbKMSvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 13:51:20 -0500
In-Reply-To: <CA+5PVA7bbnn+29+pc-JwXDUtNn36Eab0K7U1hOY09hf3T-7q1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2015, Josh Boyer wrote:

> On Wed, Nov 11, 2015 at 12:33 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > Jozsef Kadlecsik (3):
> >       netfilter: ipset: Fix extension alignment
> >       netfilter: ipset: Fix hash:* type expiration
> >       netfilter: ipset: Fix hash type expire: release empty hash bucket block
> 
> Should these three go to stable?  We've had reports in Fedora about
> ipset crashing on e.g. ARM architectures with 4.2.y kernels.  If not
> all three, then perhaps just the alignment fix?

Yes, those should definitely go to stable, at least the first two ones.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
