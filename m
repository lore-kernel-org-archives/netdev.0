From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v9 06/10] arm64: dts: allwinner: Restore EMAC changes
Date: Mon, 30 Oct 2017 19:51:30 +0100
Message-ID: <20171030185130.GB16723@Red>
References: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
 <20171024175714.15840-7-clabbe.montjoie@gmail.com>
 <20171027151114.ax2yhf75lbho2js5@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171027151114.ax2yhf75lbho2js5@flea>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 27, 2017 at 05:11:14PM +0200, Maxime Ripard wrote:
> On Tue, Oct 24, 2017 at 07:57:10PM +0200, Corentin Labbe wrote:
> > The original dwmac-sun8i DT bindings have some issue on how to handle
> > integrated PHY and was reverted in last RC of 4.13.
> > But now we have a solution so we need to get back that was reverted.
> > 
> > This patch restore arm64 DT about dwmac-sun8i
> > This reverts commit 87e1f5e8bb4b ("arm64: dts: allwinner: Revert EMAC changes")
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts   | 16 ++++++++++++++++
> >  .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts    | 15 +++++++++++++++
> >  arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts  | 17 +++++++++++++++++
> >  .../dts/allwinner/sun50i-a64-sopine-baseboard.dts    | 16 ++++++++++++++++
> >  arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi        | 20 ++++++++++++++++++++
> >  .../boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts     | 17 +++++++++++++++++
> >  .../boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts    | 17 +++++++++++++++++
> >  .../boot/dts/allwinner/sun50i-h5-orangepi-prime.dts  | 17 +++++++++++++++++
> >  8 files changed, 135 insertions(+)
> 
> Can you split the changes between the A64 and the H5? It's going to be
> difficult to merge otherwise.
> 
> (You also forgot to add Florian's Acked-by on your whole serie).
> 

Will do

Thanks
Regards
