From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: AT91: Remove fixed mapping for AT91RM9200 ethernet
Date: Wed, 11 May 2011 06:02:49 +0200
Message-ID: <20110511040249.GB22009@game.jcrosoft.org>
References: <1304884489.6089.13.camel@redbox>
	<20110511034901.GA22009@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org
To: Andrew Victor <avictor.za@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110511034901.GA22009@game.jcrosoft.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 05:49 Wed 11 May     , Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 21:54 Sun 08 May     , Andrew Victor wrote:
> > The AT91RM9200 Ethernet controller still has a fixed IO mapping.
> > So:
> > * Remove the fixed IO mapping and AT91_VA_BASE_EMAC definition.
> > * Pass the physical base-address via platform-resources to the driver.
> > * Convert at91_ether.c driver to perform an ioremap().
> > * Ethernet PHY detection needs to be performed during the driver
> > initialization process, it can no longer be done first.
> we need to pass the irq too as the hw ip does not belong to Atmel
> so it can be attached to any irq
> 
> ca we split is in two file on for -net and the other one for at91 tree
forget we can not split it

David don't you mind if we apply it through the at91 tree

Best Regards,
J.
> 
> Best Regards,
> J.
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
