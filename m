From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH][BUILD FAILURE 03/04] Next June 04:PPC64 randconfig
	[drivers/net/lance.o]
Date: Mon, 15 Jun 2009 19:43:01 +1000
Message-ID: <1245058981.12400.3.camel@pasglop>
References: <20090611035046.22125.26641.sendpatchset@subratamodak.linux.ibm.com>
	<1245048698.5239.9.camel@subratamodak.linux.ibm.com>
	<1245049899.19217.56.camel@pasglop>
	<1245050509.5239.11.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Linux-Next <linux-next@vger.kernel.org>, Paul Mackerras <paulus@samba.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: subrata@linux.vnet.ibm.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1245050509.5239.11.camel@subratamodak.linux.ibm.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-06-15 at 12:51 +0530, Subrata Modak wrote:
> On Mon, 2009-06-15 at 17:11 +1000, Benjamin Herrenschmidt wrote:
> > On Mon, 2009-06-15 at 12:21 +0530, Subrata Modak wrote:
> > 
> > > Benjamin,
> > > 
> > > I am not sure whether you liked the following patch to solve the above
> > > problem. Do, you want me address some other issue(s)/fixes for this ?
> > 
> > I suppose ... in fact some old PReP machines can even have ISA slots
> > iirc, but it's not going to do good with machines that have an iommu...
> > 
> > IE. Nobody should use that crap, period.
> 
> Great,
> 
> Can you please make some changes at drivers/net/Kconfig so that this guy
> does not build for the PPC64 systems ?

When I said "that crap" I was talking about those interfaces which I
-hope- are deprecated :-)

I suspect we never really sorted out the issue of DMA mapping for old
legacy ISA stuff... pci_map_* should work to some extent, though you
have to pass it the ISA bridge pci_dev.

Maybe it's time for somebody to start exposing a -proper- abstraction
accross all platforms for that :-)

Ben.
