From: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual
	network	device	driver.
Date: Tue, 9 May 2006 15:00:27 +0100
Message-ID: <20060509140027.GD7834@cl.cam.ac.uk>
References: <20060509131632.GB7834@cl.cam.ac.uk>
	<E1FdSDz-0008Lv-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, ian.pratt@xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FdSDz-0008Lv-00@gondolin.me.apana.org.au>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, May 09, 2006 at 11:26:03PM +1000, Herbert Xu wrote:
> Christian Limpach <Christian.Limpach@cl.cam.ac.uk> wrote:
> > 
> > Possibly having to page in the process and switching to it would add
> > to the live migration time.  More importantly, having to install an
> > additional program in the guest is certainly not very convenient.
> 
> Sorry I'm still not convinced.  What's there to stop me from suspending
> my laptop to disk, moving it from port A to port B and resuming it?
> 
> Wouldn't I be in exactly the same situation? By the same reasoning we'd
> be adding a gratuitous ARP routine to every single laptop network driver.

It is the same situation except that in the laptop case you don't care
that reconfiguring your network will take a second or a few.  For live
migration we're looking at network downtime from as low as 60ms to
something like 210ms on a busy virtual machine.  I'm not saying that
a userspace solution wouldn't work but it would probably add a measurable
delay to the network downtime during live migration.

You might also find the following paper an interesting read:
http://www.cl.cam.ac.uk/Research/SRG/netos/papers/2005-migration-nsdi-pre.pdf

    christian
