From: Xing Zheng <zhengxing@rock-chips.com>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: add rk322x-specific data
Date: Tue, 21 Jun 2016 20:12:50 +0800
Message-ID: <57692F42.30709@rock-chips.com>
References: <1466493235-17789-1-git-send-email-zhengxing@rock-chips.com>
 <3520853.j0ALyW964u@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rockchip@lists.infradead.org, roger.chen@rock-chips.com,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3520853.j0ALyW964u@diego>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Heiko,

On 2016=E5=B9=B406=E6=9C=8821=E6=97=A5 17:43, Heiko St=C3=BCbner wrote:
> devicetree names are normally expected to be real, aka no "x" as catc=
hall. So
> I guess either just add compatibles for both the rk3228 and rk3229 wh=
ich point
> to the same structure in the driver. (So driver-side can stay as it i=
s below,
> just add a second compatible).
OK, I try to just use "rockchip,rk3228-gmac" to point to "rk322x_ops"=20
which is the same structure in MAC driver,
and both rk3228 and rk3229 use it.

Thanks

--=20
- Xing Zheng
