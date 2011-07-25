From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skbuff: clear tx zero-copy flag
Date: Mon, 25 Jul 2011 03:02:29 -0700 (PDT)
Message-ID: <20110725.030229.1448266647053398033.davem@davemloft.net>
References: <20110725084057.GA30311@gondor.apana.org.au>
	<20110725094414.GA11776@redhat.com>
	<20110725095711.GA30831@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, mashirle@us.ibm.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110725095711.GA30831@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Mon, 25 Jul 2011 17:57:11 +0800

> However, I think we should add a WARN_ON to the splice skb path
> so that should a packet find its way through a path that we haven't
> thought of then at least we'll know about it.

Good idea.
