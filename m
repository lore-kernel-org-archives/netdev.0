From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [RFC PATCH 32/33] Add the Xen virtual network
	device driver.
Date: Tue, 18 Jul 2006 11:35:38 +0100
Message-ID: <278d0ba5a24d74c5b590dd76d234c312@cl.cam.ac.uk>
References: <20060718091807.467468000@sous-sol.org>
	<20060718091958.414414000@sous-sol.org>
	<1153218477.3038.46.camel@laptopd505.fenrus.org>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel@lists.xensource.com, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Wright <chrisw@sous-sol.org>, Ian Pratt <ian.pratt@xensource.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1153218477.3038.46.camel@laptopd505.fenrus.org>
To: Arjan van de Ven <arjan@infradead.org>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org


On 18 Jul 2006, at 11:27, Arjan van de Ven wrote:

> Hmmm maybe it's me, but something bugs me if a NIC driver is going to
> send IP level ARP packets... that just feels very very wrong and is a
> blatant layering violation.... shouldn't the ifup/ifconfig scripts just
> be fixed instead if this is critical behavior?

Maybe we should be faking this out from our hotplug scripts in the 
control VM, although triggering this from user space is probably a bit 
of a pain. Regardless, the function can be removed from the driver if 
it's too distasteful: it's only a performance 'hack' to get network 
traffic more quickly redirected when migrating a VM between physical 
hosts. Things won't break horribly if it's removed.

  -- Keir
