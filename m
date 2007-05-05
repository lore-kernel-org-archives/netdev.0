From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 25/29] xen: Add the Xen virtual network device driver.
Date: Sat, 5 May 2007 20:23:05 +1000
Message-ID: <20070505102305.GA12771@gondor.apana.org.au>
References: <20070504232051.411946839@goop.org>
	<20070504232121.492190579@goop.org>
	<20070505091624.GA8890@infradead.org> <463C56D3.8060609@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, Jeff Garzik <jeff@garzik.org>,
        Ian Pratt <ian.pratt@xensource.com>, netdev@vger.kernel.org,
        lkml <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>, virtualization@lists.osdl.org,
        Keir Fraser <Keir.Fraser@cl.cam.ac.uk>,
        Stephen Hemminger <shemminge@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <463C56D3.8060609@goop.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, May 05, 2007 at 03:05:07AM -0700, Jeremy Fitzhardinge wrote:
>
> Sorry, I forgot about it.  I was waiting to hear back from network
> people about what this is actually for, and whether we really need it. 

We should just change this to use netif_device_attach and
netif_device_detach.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
