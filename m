From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] ipv4: Simplify raw_probe_proto_opt and avoid reading
 user iov twice
Date: Fri, 7 Nov 2014 21:25:53 +0800
Message-ID: <20141107132553.GA20190@gondor.apana.org.au>
References: <20141106055023.GA28865@gondor.apana.org.au>
 <20141106064318.GW7996@ZenIV.linux.org.uk>
 <20141106064629.GA29321@gondor.apana.org.au>
 <20141106.162808.1546139916210194279.davem@davemloft.net>
 <20141107020025.GC9101@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org, nakam@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141107020025.GC9101@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

This series rewrites the function raw_probe_proto_opt in a more
readable fasion, and then fixes the long-standing bug where we
read the probed bytes twice which means that what we're using to
probe may in fact be invalid.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
