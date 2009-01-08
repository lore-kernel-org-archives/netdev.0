From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 08 Jan 2009 11:16:10 -0800 (PST)
Message-ID: <20090108.111610.132149837.davem__11065.8017256812$1231443944$gmane$org@davemloft.net>
References: <20090107195052.GA24981@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org
To: iws@ovro.caltech.edu
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090107195052.GA24981@ovro.caltech.edu>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Ira Snyder <iws@ovro.caltech.edu>
Date: Wed, 7 Jan 2009 11:50:52 -0800

> This adds support to Linux for a virtual ethernet interface which uses the
> PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> method of communication for two devices connected by a PCI interface.

Well, it looks like much more than that to me.

What is this UART thing in here for?

I can only assume it's meant to be used as a console port between the
x86 host and the powerpc nodes.

You haven't even mentioned this UART aspect even indirectly in the
commit message.

This just looks like yet another set of virtualization drivers
to me.  You could have just have easily built this using your
own PCI backplane framework, and using the virtio stuff on top.

And the virtio stuff has all kinds of snazzy optimizations that
will likely improve your throughput, it has console drivers that
distributions already probe for and attach appropriately, etc.

In short I really don't like this conceptually, it can be done
so much better using facilities we already have that are
heavily optimized and userland understands already.
