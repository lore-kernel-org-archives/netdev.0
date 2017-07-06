From: Chris Paterson <Chris.Paterson2@renesas.com>
Subject: RE: [PATCH v2 2/2] ARM: shmobile: defconfig: Enable Ethernet AVB
Date: Thu, 6 Jul 2017 08:05:43 +0000
Message-ID: <TY1PR06MB07020F58F15C964FC1AA1D22B7D50@TY1PR06MB0702.apcprd06.prod.outlook.com>
References: <afcd181c-c805-8f3c-955f-652d001a03d4@cogentembedded.com>
 <1499270189-29945-1-git-send-email-biju.das@bp.renesas.com>
 <1499270189-29945-3-git-send-email-biju.das@bp.renesas.com>
 <12c32eee-8e4d-457e-97d7-625a5c63ad59@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Magnus Damm <magnus.damm@gmail.com>,
 "linux-renesas-soc@vger.kernel.org" <linux-renesas-soc@vger.kernel.org>,
 Simon Horman <horms@verge.net.au>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Biju Das
 <biju.das@bp.renesas.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland
 <mark.rutland@arm.com>, Russell King <linux@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <12c32eee-8e4d-457e-97d7-625a5c63ad59@cogentembedded.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Sergei, 

Thank you for your comments.

> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: 05 July 2017 17:14
> 
> Hello!
> 
> On 07/05/2017 06:56 PM, Biju Das wrote:
> 
> > The iWave RZ/G1M Q7 SOM supports Gigabit Ethernet Phy (Micrel
> KSZ9031MNX).
> > Gigabit Ethernet support is available in Renesas AVB driver.
> > To increase hardware support enable the driver in the
> > shmobile_defconfig multiplatform configuration.
> >
> > Signed-off-by: Biju Das <biju.das@bp.renesas.com>
> > Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>
> > Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>
> > ---
> >  arch/arm/configs/shmobile_defconfig | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/arch/arm/configs/shmobile_defconfig
> > b/arch/arm/configs/shmobile_defconfig
> > index 3c66a42..d992911 100644
> > --- a/arch/arm/configs/shmobile_defconfig
> > +++ b/arch/arm/configs/shmobile_defconfig
> > @@ -83,6 +83,7 @@ CONFIG_NETDEVICES=y
> >  # CONFIG_NET_VENDOR_MICREL is not set  #
> CONFIG_NET_VENDOR_NATSEMI is
> > not set  CONFIG_SH_ETH=y
> > +CONFIG_RAVB=y
> 
>     Hm, I would enable it only as a module, given it's not easy to make use of
> AVB on the 32-bit boards.

On the iWave-M platforms the only available Ethernet interface is AVB. Without including the RAVB driver in the Kernel we won't be able to use NFS.

I know adding CONFIG_RAVB for all shmobile devices may increase the Kernel size for everyone, especially when most cannot use AVB without an add-on board, but I don't think the increase will be big.


Kind regards, Chris 

> 
> [...]
> 
> MBR Sergei
