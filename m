From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Tue, 24 Nov 2015 18:34:55 +0800
Message-ID: <20151124103455.GB623@gondor.apana.org.au>
References: <cover.1448299690.git.davejwatson@fb.com>
 <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 23, 2015 at 09:43:02AM -0800, Dave Watson wrote:
> Userspace crypto interface for TLS.  Currently supports gcm(aes) 128bit only,
> however the interface is the same as the rest of the SOCK_ALG interface, so it
> should be possible to add more without any user interface changes.

SOCK_ALG exists to export crypto algorithms to user-space.  So if
we decided to support TLS as an algorithm then I guess this makes
sense.

However, I must say that it wouldn't have been my first pick.  I'd
imagine a TLS socket to look more like a TCP socket, or perhaps a
KCM socket as proposed by Tom.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
