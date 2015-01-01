From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH v3 0/6] support GMAC driver for RK3288
Date: Thu, 01 Jan 2015 03:06:31 +0100
Message-ID: <1493383.y3pPThNXY3@phil>
References: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com> <20141231.191538.585375391107637966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: roger.chen@rock-chips.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rockchip@lists.infradead.org, kever.yang@rock-chips.com,
	eddie.cai@rock-chips.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141231.191538.585375391107637966.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Am Mittwoch, 31. Dezember 2014, 19:15:38 schrieb David Miller:
> From: Roger Chen <roger.chen@rock-chips.com>
> Date: Mon, 29 Dec 2014 17:42:32 +0800
> 
> > Roger Chen (6):
> >   patch1: add driver for Rockchip RK3288 SoCs integrated GMAC
> >   patch2: define clock ID used for GMAC
> >   patch3: modify CRU config for Rockchip RK3288 SoCs integrated GMAC
> >   patch4: dts: rockchip: add gmac info for rk3288
> >   patch5: dts: rockchip: enable gmac on RK3288 evb board
> >   patch6: add document for Rockchip RK3288 GMAC
> > 
> > Tested on rk3288 evb board:
> > Execute the following command to enable ethernet,
> > set local IP and ping a remote host.
> > 
> > busybox ifconfig eth0 up
> > busybox ifconfig eth0 192.168.1.111
> > ping 192.168.1.1
> 
> Series applied to net-next, thanks.

could we split this up a bit instead?

If everything goes through your tree, we'll end up with a lot of conflicts with 
other pending stuff, so I'd really appreciate if you could leave out patches
 
   patch2: define clock ID used for GMAC
   patch3: modify CRU config for Rockchip RK3288 SoCs integrated GMAC
   patch4: dts: rockchip: add gmac info for rk3288
   patch5: dts: rockchip: enable gmac on RK3288 evb board

so only take the driver itself and the dt-binding and I would take these 4 
above through the appropriate trees (clk and arm-soc)


Thanks and happy new year
Heiko
