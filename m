From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ppp: build ifname using unit identifier for
 rtnl based devices
Date: Tue, 09 Aug 2016 15:06:24 -0700 (PDT)
Message-ID: <20160809.150624.845634212821004691.davem@davemloft.net>
References: <20160809131226.wxqmmiogluudr4sn@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: g.nault@alphalink.fr
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20160809131226.wxqmmiogluudr4sn@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 9 Aug 2016 15:12:26 +0200

> Userspace programs generally need to know the name of the ppp devices
> they create. Both ioctl and rtnl interfaces use the ppp<suffix> sheme
> to name them. But although the suffix used by the ioctl interface can
> be known by userspace (it's the PPP unit identifier returned by the
> PPPIOCGUNIT ioctl), the one used by the rtnl is only known by the
> kernel.
> 
> This patch brings more consistency between ioctl and rtnl based ppp
> devices by generating device names using the PPP unit identifer as
> suffix in both cases. This way, userspace can always infer the name of
> the devices they create.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied, thanks.
