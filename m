From: Anton Blanchard <anton@samba.org>
Subject: Re: TSO + e1000
Date: Mon, 6 Dec 2004 12:43:49 +1100
Message-ID: <20041206014348.GB8751@krispykreme.ozlabs.ibm.com>
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

 
> > Now if we do a single direction test it takes forever for TSO to kick
> > in. At the moment Im not sure why this is happening, tcp_current_mss
> > seems to grow correctly in both cases. Is there somewhere else we are
> > capping TSO packets?
> 
> What call does your application use to do the sending?

Just doing big writes:

send(4, " !\"#$%&\'()*+,-./0123456789:;<=>?"..., 262144, 0) = 262144

Anton
