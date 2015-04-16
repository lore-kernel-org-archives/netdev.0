From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Thu, 16 Apr 2015 12:20:06 +0800
Message-ID: <20150416042005.GA12179@gondor.apana.org.au>
References: <1429121867.7346.136.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefano.stabellini@eu.citrix.com, george.dunlap@eu.citrix.com,
	Jonathan.Davies@citrix.com, xen-devel@lists.xensource.com,
	wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, paul.durrant@citrix.com,
	christoffer.dall@linaro.org, felipe.franciosi@citrix.com,
	linux-arm-kernel@lists.infradead.org, david.vrabel@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429121867.7346.136.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> We already have netdev->gso_max_size and netdev->gso_max_segs
> which are cached into sk->sk_gso_max_size & sk->sk_gso_max_segs

It is quite dangerous to attempt tricks like this because a
tc redirection or netfilter nat could change the destination
device rendering such hints incorrect.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
