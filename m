From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] ixgbe: Introduce MSI-X queue vector
	code
Date: Wed, 05 Mar 2008 06:30:33 -0500
Message-ID: <47CE8459.6080006@garzik.org>
References: <20080303230345.25151.48298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080303230345.25151.48298.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
> 
> This code abstracts the per-queue MSI-X interrupt vector into
> a queue vector layer. This abstraction is needed since there can
> be many more queues than available MSI-X vectors in a machine.
> 
> The MSI-X irq vectors are remapped to a shared queue vector which
> can point to several (both RX and TX) hardware queues. The NAPI
> algorithm then cleans the appropriate ring/queues on interrupt
> or poll.
> 
> The remapping is a delicate and complex calculation to make sure
> that we're not unbalancing the irq load, and spreads the irqs
> as much as possible, and may combine RX and TX flows onto the
> same queue vector.
> 
> This effectively enables receive flow hashing across vectors
> and helps irq load balance across CPUs.
> 
> Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Acked-by: Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com>

applied 1-5 to #upstream (2.6.26)



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
