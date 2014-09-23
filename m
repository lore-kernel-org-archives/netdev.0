From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell
 PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 16:29:22 +0200
Message-ID: <20140923142922.GE18924@kwain>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
 <1411474536-22626-4-git-send-email-antoine.tenart@free-electrons.com>
 <51745791.Wuu5QiQB2e@wuerfel> <20140923140113.GC18924@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 jszhang@marvell.com, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20140923140113.GC18924@kwain>
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

On Tue, Sep 23, 2014 at 04:01:13PM +0200, Antoine Tenart wrote:
> Arnd,
> =

> On Tue, Sep 23, 2014 at 02:38:39PM +0200, Arnd Bergmann wrote:
> > On Tuesday 23 September 2014 14:15:30 Antoine Tenart wrote:
> > > +Optional properties:
> > > +- port-id: should be '0','1' or '2'.
> > > +- phy-addr: MDIO address of the PHY.
> > > +- local-mac-address: see ethernet.txt file in the same directory.
> > > +
> > > =

> > =

> > I believe new bindings should not use "phy-addr" properties, but
> > instead use a phy-handle property pointing to a phy device instead.
> =


So I had a look on other Ethernet bindings. Would you agree with
something like the following?

	eth0: ethernet@f7b90000 {
		...
		#address-cells =3D <1>;
		#size-cells =3D <0>;
		phy-handle =3D <&ethphy0>;

		ethphy0: ethernet-phy@0 {
			reg =3D <0>;
		};
	};

Antoine

-- =

Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
