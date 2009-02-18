From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Wed, 18 Feb 2009 13:50:43 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902181345010.31742@wrl-59.cs.helsinki.fi>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>
 <20090212001223.GA5757@movementarian.org>  <alpine.DEB.2.00.0902121006440.18739@blackhole.kfki.hu>
 <f73f7ab80902120546w2ac30501v10fc55b9c8270be9@mail.gmail.com>
 <alpine.DEB.2.00.0902171723330.27283@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Kyle Moffett <kyle@moffetthome.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0902171723330.27283@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2009, Jozsef Kadlecsik wrote:

> On Thu, 12 Feb 2009, Rusty Russell wrote:
> 
> > My concern was that it's also bigger (and we inline it).  Performance is
> > pretty much a wash since we so rarely hash more than a few words.
> 
> In netfilter/conntrack (;-) we call the hash function for every packet, so 
> even if a small number of cycle can be gained at one lookup, I think it's 
> worth. And in the IPv4/IPv6 neutral nf_conntrack we hash 9 words.

FYI, I once looked into inlining cost and jhash functions were among the 
most wasteful (kernel-wide). Multiple jhash bodies were 100+ bytes, and 
the overall cost was 10k+. I never got to the final submit of the 
uninlining patch though...


-- 
 i.
