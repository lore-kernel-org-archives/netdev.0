From: James Morris <jmorris@redhat.com>
Subject: Re: IPCOMP scratch buffer (was: [Openswan dev] IPComp)
Date: Fri, 9 Jul 2004 10:03:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407091002420.3887-100000@thoron.boston.redhat.com>
References: <20040709100213.GA12215@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040709100213.GA12215@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jul 2004, Herbert Xu wrote:

> > scratch buffer for each packet, based on the size of the packet.  IPComp
> > is very slow path, and allocating 64k for each SA is optimizing for an
> > uncommon worst case in a way which will potentially eat up a lot of memory
> > (e.g. > 6MB for 100 tunnels).
> 
> What about a shared per-cpu buffer?
> 

You can try if you like.


- James
-- 
James Morris
<jmorris@redhat.com>
