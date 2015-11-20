From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: how to deal with that rhashtable_lookup_insert_key
 return -EBUSY
Date: Fri, 20 Nov 2015 20:25:44 +0800
Message-ID: <20151120122544.GA17528@gondor.apana.org.au>
References: <CADvbK_drKzCbByS38==rkC8yRtQhRj6mOtKAgXeHLwOhdh6Z1Q@mail.gmail.com>
 <20151120122401.GB16648@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, Xin Long <lucien.xin@gmail.com>,
	linux-kernel@vger.kernel.org, network dev <netdev@vger.kernel.org>,
	tgraf@suug.ch, davem <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151120122401.GB16648@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2015 at 01:24:01PM +0100, Phil Sutter wrote:
>
> Herbert, did you manage to reproduce the problem meanwhile? If so, was
> there any progress on fixing rhashtable? Otherwise, I could respin my
> patch from [1] to cover only -EBUSY case by default and add a parameter
> to make non-permanent -ENOMEM visible.

No I have not been able to reproduce this yet.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
