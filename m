From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: IPCOMP scratch buffer (was: [Openswan dev] IPComp)
Date: Fri, 9 Jul 2004 20:02:13 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709100213.GA12215@gondor.apana.org.au>
References: <20040706213135.GA21477@gondor.apana.org.au> <Xine.LNX.4.44.0407061846470.24263-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0407061846470.24263-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 06, 2004 at 06:50:44PM -0400, James Morris wrote:
> 
> I think it would be better to go with your original idea of allocating a
> scratch buffer for each packet, based on the size of the packet.  IPComp
> is very slow path, and allocating 64k for each SA is optimizing for an
> uncommon worst case in a way which will potentially eat up a lot of memory
> (e.g. > 6MB for 100 tunnels).

What about a shared per-cpu buffer?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
