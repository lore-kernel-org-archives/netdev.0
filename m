From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: Re: [PATCH] net: fec: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 08:06:33 +0200
Message-ID: <5232AB69.8050900@free-electrons.com>
References: <1379043878-6376-1-git-send-email-michael.opdenacker@free-electrons.com> <9848F2DB572E5649BA045B288BE08FBE016DAF7D@039-SN2MPN1-022.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"frank.li@freescale.net" <frank.li@freescale.net>,
	"jim_baxter@mentor.com" <jim_baxter@mentor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE016DAF7D@039-SN2MPN1-022.039d.mgd.msft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

Thank you for your time reviewing this patch.

On 09/13/2013 06:45 AM, Duan Fugang-B38611 wrote:
>
> Can you remove the flag for all net driver such as:
>
> /linux-next/linux-2.6$ grep -nr "IRQF_DISABLED" drivers/net/ethernet/
> drivers/net/ethernet/adi/bfin_mac.c:533:                                 IRQF_DISABLED, "EMAC_WAKE", dev);
> drivers/net/ethernet/adi/bfin_mac.c:1689:                       IRQF_DISABLED, "EMAC_RX", ndev);
> drivers/net/ethernet/lantiq_etop.c:285:                 request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
> drivers/net/ethernet/lantiq_etop.c:294:                 request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
> drivers/net/ethernet/micrel/ks8851_mll.c:918:#define    KS_INT_FLAGS    (IRQF_DISABLED|IRQF_TRIGGER_LOW)
> drivers/net/ethernet/pasemi/pasemi_mac.c:1222:  ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, IRQF_DISABLED,
> drivers/net/ethernet/pasemi/pasemi_mac.c:1233:  ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, IRQF_DISABLED,
> drivers/net/ethernet/amd/sun3lance.c:361:       if (request_irq(LANCE_IRQ, lance_interrupt, IRQF_DISABLED, "SUN3 Lance", dev) < 0) {
> drivers/net/ethernet/dec/tulip/de4x5.c:356:                       Added IRQF_DISABLED temporary fix from
> drivers/net/ethernet/dec/tulip/de4x5.c:1324:    if (request_irq(dev->irq, de4x5_interrupt, IRQF_DISABLED | IRQF_SHARED,
> drivers/net/ethernet/freescale/fec_main.c:2212:                                IRQF_DISABLED, pdev->name, ndev);
> drivers/net/ethernet/smsc/smc91x.h:274:#define SMC_IRQ_FLAGS            (IRQF_DISABLED)
> drivers/net/ethernet/smsc/smsc9420.c:1359:      result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
> drivers/net/ethernet/ibm/ehea/ehea_main.c:1288:                           IRQF_DISABLED, port->int_aff_name, port);
> drivers/net/ethernet/ibm/ehea/ehea_main.c:1306:                                   IRQF_DISABLED, pr->int_send_name,
> drivers/net/ethernet/ibm/ehea/ehea_main.c:3323:                           ehea_interrupt_neq, IRQF_DISABLED,
> drivers/net/ethernet/korina.c:999:                      IRQF_DISABLED, "Korina ethernet Rx", dev);
> drivers/net/ethernet/korina.c:1006:                     IRQF_DISABLED, "Korina ethernet Tx", dev);
> drivers/net/ethernet/korina.c:1015:                     IRQF_DISABLED, "Ethernet Overflow", dev);
> drivers/net/ethernet/korina.c:1024:                     IRQF_DISABLED, "Ethernet Underflow", dev);
> drivers/net/ethernet/marvell/pxa168_eth.c:1127:                   IRQF_DISABLED, dev->name, dev);
> drivers/net/ethernet/natsemi/jazzsonic.c:86:    retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
> drivers/net/ethernet/natsemi/xtsonic.c:98:      retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
> drivers/net/ethernet/toshiba/ps3_gelic_net.c:1729:                           IRQF_DISABLED, netdev->name, card);
> drivers/net/ethernet/hp/hp100.c:1100:                   HP100_BUS_EISA ? IRQF_SHARED : IRQF_DISABLED,
> drivers/net/ethernet/broadcom/bcm63xx_enet.c:929:       ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
> drivers/net/ethernet/broadcom/bcm63xx_enet.c:935:                         IRQF_DISABLED, dev->name, dev);
> drivers/net/ethernet/broadcom/bcm63xx_enet.c:2159:                        IRQF_DISABLED, dev->name, dev);
> drivers/net/ethernet/broadcom/bcm63xx_enet.c:2165:                                IRQF_DISABLED, dev->name, dev);
Already done, through separate patches. Some have already been merged by
Dave Miller.

Cheers,

Michael.

-- 
Michael Opdenacker, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
+33 484 258 098
