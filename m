From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become
 free. Usage count = 1
Date: Sun, 13 Jun 2004 21:43:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040613214355.772af3a6.davem@redhat.com>
References: <20040613121514.6b3c1c8a.davem@redhat.com>
	<E1BZeW1-0008Ny-00@gondolin.me.apana.org.au>
	<20040613234142.GA32329@gondor.apana.org.au>
	<20040613183622.3a814506.davem@redhat.com>
	<20040614015013.GA11048@gondor.apana.org.au>
	<20040613210725.70dbd016.davem@redhat.com>
	<20040614042216.GA28669@gondor.apana.org.au>
	<20040613212708.1903d54c.davem@redhat.com>
	<20040614044240.GA28844@gondor.apana.org.au>
	<20040614044717.GA28929@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: schwab@suse.de, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040614044717.GA28929@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jun 2004 14:47:17 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> And there's more :) The work done in ifdown also falls in the same
> category.  Its work will be carried out in the GC anyway.
> 
> Actually in all these cases it could take a lot more than two minutes
> if there is a long-living entity (maybe a TCP connection) holding onto
> the dst.  So I guess #1 and #2 should be addressed at some point.

Maybe the solution is to initiate a GC run as soon as possible
instead of however long into the future it would have ended
up running.

Wouldn't that help?
