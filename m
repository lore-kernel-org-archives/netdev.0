From: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual
	network	device	driver.
Date: Tue, 9 May 2006 14:16:32 +0100
Message-ID: <20060509131632.GB7834@cl.cam.ac.uk>
References: <20060509124359.GA5407@cl.cam.ac.uk>
	<E1FdRpp-0008HG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, ian.pratt@xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FdRpp-0008HG-00@gondolin.me.apana.org.au>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, May 09, 2006 at 11:01:05PM +1000, Herbert Xu wrote:
> Christian Limpach <Christian.Limpach@cl.cam.ac.uk> wrote:
> > 
> > There's at least two reasons why having it in the driver is preferable:
> > - synchronizing sending the fake ARP request with when the device is
> >  operational -- you really want to make this well synchronized to keep
> >  unreachability as short as possible, especially when doing live
> >  migration
> > - anybody but the guest might not know (all) the MAC addresses for which
> >  to send a fake ARP request
> 
> Sure.  However, what's there to stop you from doing this in user-space
> inside the guest?

Possibly having to page in the process and switching to it would add
to the live migration time.  More importantly, having to install an
additional program in the guest is certainly not very convenient.

    christian
