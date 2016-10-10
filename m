From: Jean-Francois Moine <moinejf@free.fr>
Subject: Re: [PATCH v4 10/10] ARM: sunxi: Enable sun8i-emac driver on
 multi_v7_defconfig
Date: Mon, 10 Oct 2016 15:09:43 +0200
Message-ID: <20161010150943.fa7ca85fe52f4c6f9508b5eb@free.fr>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-11-git-send-email-clabbe.montjoie@gmail.com>
 <20161010123046.GH3462@lukather> <20161010123511.GA16103@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 Maxime Ripard <maxime.ripard@free-electrons.com>, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161010123511.GA16103@Red>
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

On Mon, 10 Oct 2016 14:35:11 +0200
LABBE Corentin <clabbe.montjoie@gmail.com> wrote:

> On Mon, Oct 10, 2016 at 02:30:46PM +0200, Maxime Ripard wrote:
> > On Fri, Oct 07, 2016 at 10:25:57AM +0200, Corentin Labbe wrote:
> > > Enable the sun8i-emac driver in the multi_v7 default configuration
> > > =

> > > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > > ---
> > >  arch/arm/configs/multi_v7_defconfig | 1 +
> > >  1 file changed, 1 insertion(+)
> > > =

> > > diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/m=
ulti_v7_defconfig
> > > index 5845910..f44d633 100644
> > > --- a/arch/arm/configs/multi_v7_defconfig
> > > +++ b/arch/arm/configs/multi_v7_defconfig
> > > @@ -229,6 +229,7 @@ CONFIG_NETDEVICES=3Dy
> > >  CONFIG_VIRTIO_NET=3Dy
> > >  CONFIG_HIX5HD2_GMAC=3Dy
> > >  CONFIG_SUN4I_EMAC=3Dy
> > > +CONFIG_SUN8I_EMAC=3Dy
> > =

> > Any reason to build it statically?
> > =

> =

> No, just copied the same than CONFIG_SUN4I_EMAC that probably do not need=
 it also.

All arm configs are done the same way, and, some day, the generic ARM
V7 kernel will not be loadable in 1Gb RAM...

-- =

Ken ar c'henta=F1	|	      ** Breizh ha Linux atav! **
Jef		|		http://moinejf.free.fr/
