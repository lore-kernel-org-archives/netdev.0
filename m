From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Tue, 24 Nov 2015 06:50:40 -0500
Message-ID: <20151124115040.GK30089@oracle.com>
References: <cover.1448299690.git.davejwatson@fb.com>
 <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
 <20151124103455.GB623@gondor.apana.org.au>
 <9662204.R2y95MbYda@tauon.atsec.com>
 <871tbfhcf3.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephan Mueller <smueller@chronox.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <871tbfhcf3.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (11/24/15 12:20), Hannes Frederic Sowa wrote:
> There are some crypto acclerators out there so that putting tls into the
> kernel would give a net benefit, because otherwise user space has to
> copy data into the kernel for device access and back to user space until
> it can finally be send out on the wire.
> 
> Since processors provide aesni and other crypto extensions as part of
> their instruction set architecture, this, of course, does not make sense
> any more.

BTW, that, exactly, was what happened to Solaris kssl. 

--Sowmini
