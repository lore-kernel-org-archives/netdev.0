From: Anton Blanchard <anton@samba.org>
Subject: Re: TSO + e1000
Date: Mon, 6 Dec 2004 15:16:56 +1100
Message-ID: <20041206041656.GE8751@krispykreme.ozlabs.ibm.com>
References: <20041205232226.GA5757@krispykreme.ozlabs.ibm.com> <E1Cb7dy-000588-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com, john.ronciak@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1Cb7dy-000588-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> This is a bug in e1000.  Even if it is required it isn't allowed to
> modify a cloned packet.  It'll need to copy it so that other clone
> users aren't affected.

It looks like the tg3 is doing a similar thing.

Anton
