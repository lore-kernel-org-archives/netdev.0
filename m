From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH] net/core: Order-3 frag allocator causes
 SWIOTLB bouncing under Xen
Date: Thu, 5 Sep 2013 08:39:06 +0100
Message-ID: <1378366746.6935.35.camel@dagon.hellion.org.uk>
References: <1378327638-23956-1-git-send-email-zoltan.kiss@citrix.com>
	 <1378328440.7360.124.camel@edumazet-glaptop>
	 <20130904211110.GA17758@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org,
	Eric Dumazet <edumazet@google.com>,
	Li Zefan <lizefan@huawei.com>, david.vrabel@citrix.com,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	malcolm.crossley@citrix.com,
	"David S. Miller" <davem@davemloft.net>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130904211110.GA17758@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-04 at 17:11 -0400, Konrad Rzeszutek Wilk wrote:
> On Wed, Sep 04, 2013 at 02:00:40PM -0700, Eric Dumazet wrote:

> > Maybe you could add proper infrastructure to deal with Xen limitations.
> 
> I think Ian posted at some point an sysctl patch for that (more for
> debugging that anything else). And it kind
> of stalled: http://lists.xen.org/archives/html/xen-devel/2012-10/msg01832.html

I think I though you were looking into it from the swiotlb angle?

In any case I don't have time to look into this further.

> Is that what you mean by proper infrastructure ?
> 
> Oh wait, did you mean via dev and not the whole system wide sysctl?

The system wide sysctl was not acceptable AFAIR, which seems reasonable.

Per-dev is hard because it affects the native drivers for each physical
NIC when running under Xen, not the Xen PV NIC which we fixed by
splitting compound frags into separate slots on the PV ring.

Ian.
