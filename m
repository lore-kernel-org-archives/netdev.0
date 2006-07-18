From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 32/33] Add the Xen virtual network
	device driver.
Date: Tue, 18 Jul 2006 23:08:09 +1000
Message-ID: <E1G2pJ3-0003LN-00@gondolin.me.apana.org.au>
References: <1153226379.5283.51.camel@jzny2>
Cc: akpm@osdl.org, zach@vmware.com, jeremy@goop.org,
	xen-devel@lists.xensource.com, ian.pratt@xensource.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, ak@suse.de, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, Christian.Limpach@cl.cam.ac.uk,
	arjan@infradead.org
Return-path: <xen-devel-bounces@lists.xensource.com>
To: hadi@cyberus.ca
In-Reply-To: <1153226379.5283.51.camel@jzny2>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
>
> I dont think the ifup/ifconfig provide operational status (i.e link
> up/down) - or do they? If they can be made to invoke scripts in such
> a case then we are set.

In fact, that's a very good reason why this shouldn't be in netfront.
Indeed, it shouldn't be in the guest at all.  The reason is that the
guest has no idea whether the physical carrier is present.

It's much better for the host to send the ARP packet on behalf of the
guest since the host knows the carrier status and the guest's MAC
address.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
