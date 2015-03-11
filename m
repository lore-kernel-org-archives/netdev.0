From: David Miller <davem@davemloft.net>
Subject: Re: net: Remove iocb argument from sendmsg and recvmsg
Date: Wed, 11 Mar 2015 00:06:07 -0400 (EDT)
Message-ID: <20150311.000607.609650379851507833.davem@davemloft.net>
References: <54FFAA5B.3080608@intel.com>
	<54FFB3E9.50905@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tadeusz.struk@intel.com, herbert@gondor.apana.org.au, hch@lst.de,
	viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <54FFB3E9.50905@windriver.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 11 Mar 2015 11:18:01 +0800

> Sorry, I did not realize the case when I created the commit. However, although I
> don't understand its scenario, in my opinion, adding one redundant argument for
> all sockets to satisfy the special case seems unreasonable for us.

And the AIO socket mechanism was buggy and references freed up stack
objects.

That whole set of problems would need to be addressed fully before
we could even think of adding AIO support back to the socket layer.
