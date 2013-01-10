From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: Fix phy_init for Marvell network eth driver
Date: Thu, 10 Jan 2013 07:17:19 -0500
Message-ID: <20130110121719.GL5075@titan.lakedaemon.net>
References: <1357819234-27752-1-git-send-email-konszert@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alior@marvell.com, andrew@lunn.ch, netdev@vger.kernel.org,
 benavi@marvell.com, zertsekel@gmail.com, linux-arm-kernel@lists.infradead.org
To: Kosta Zertsekel <konszert@marvell.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1357819234-27752-1-git-send-email-konszert@marvell.com>
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

On Thu, Jan 10, 2013 at 02:00:32PM +0200, Kosta Zertsekel wrote:
> Hi all,
> resubmitting the patch for Marvell mv643xx driver (patch 1/2) adding the below explanation (thanks to Florian F.):
> The D-Link DNS323_REV_C1 board has a specific PHY device fixup using the flag MARVELL_PHY_M1118_DNS323_LEDS which is set by the architecture code in arch/arm/mach-orion5x/dns323-setup.c. This flag is unfortunately lost during the call to phy_attach() in mv643xx_eth and therefore, the underlying Marvell PHY driver cannot make use of this flag to fixup the PHY device LEDs. This patch ensures the phy->dev_flags value is passed to the phy_attach() function such that the PHY device driver can
> actually use it.
> 
> Also submitting new patch 2/2 using the same (or at least very close in meaning) explanation.

Could you please put the above description in the patch commit log for
both patches?  Other than that,

Acked-by: Jason Cooper <jason@lakedaemon.net>

thx,

Jason.
