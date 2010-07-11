From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Sun, 11 Jul 2010 18:24:35 +0800
Message-ID: <20100711102435.GA12919@gondor.apana.org.au>
References: <20100708222913.GA4475@redhat.com> <20100709071814.GA27964@gondor.apana.org.au> <20100711092117.GA16502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100711092117.GA16502@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 11, 2010 at 12:21:17PM +0300, Michael S. Tsirkin wrote:
>
> > I'd think that this target would be protocol-agnostic, no?
> 
> Meaning it should go into net/netfilter/? Will do.

Right, and you should get rid of any IPv4 dependencies.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
