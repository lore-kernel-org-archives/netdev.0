From: Domen Puncer <domen@coderock.org>
Subject: [PATCH] phy: export phy_mii_ioctl
Date: Mon, 17 Sep 2007 22:21:40 +0200
Message-ID: <20070917202140.GB2642@nd47.coderock.org>
References: <20070810095153.GC13994@moe.telargo.com>
	<20070902074143.GB2642@nd47.coderock.org>
	<fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
	<20070915121444.GA19857@nd47.coderock.org>
	<20070917095334.GA4546@powerlinux.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20070917095334.GA4546@powerlinux.fr>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Export phy_mii_ioctl, so network drivers can use it when built
as modules too.

Signed-off-by: Domen Puncer <domen@coderock.org>

---
On 17/09/07 11:53 +0200, Sven Luther wrote:
> On Sat, Sep 15, 2007 at 02:14:44PM +0200, Domen Puncer wrote:
> > Updated and split version at:
> > http://coderock.org/tmp/fec-v3rc1/
> > 
> > I'll repost to lists once I run-test them.
> 
> When applying those patches, the build did die with :
> 
> 
>   ERROR: "phy_mii_ioctl" [drivers/net/fec_mpc52xx/fec_mpc52xx.ko] undefined!
> 
> Apparently, phy_mii_ioctl is not an exported symbol.
> 
> Domen, did you maybe forget a little snipplet when you cut the patches
> in different pieces ? Or did i mess up applying them ?
> 
> Friendly,
> 
> Sven Luther


 drivers/net/phy/phy.c |    1 +
 1 files changed, 1 insertion(+)

Index: linux.git/drivers/net/phy/phy.c
===================================================================
--- linux.git.orig/drivers/net/phy/phy.c
+++ linux.git/drivers/net/phy/phy.c
@@ -409,6 +409,7 @@ int phy_mii_ioctl(struct phy_device *phy
 
 	return 0;
 }
+EXPORT_SYMBOL(phy_mii_ioctl);
 
 /**
  * phy_start_aneg - start auto-negotiation for this PHY device
