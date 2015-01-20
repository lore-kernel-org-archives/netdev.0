From: Romain Perier <romain.perier@gmail.com>
Subject: Re: [PATCH v1 0/4] net: stmmac: dwmac-rk: Fix phy regulator issues
Date: Tue, 20 Jan 2015 07:58:43 +0100
Message-ID: <CABgxDoLXBvrqt5SnGybWa_EbT_wGjwHj80bLvhAE3og-m-7t6A@mail.gmail.com>
References: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
	<1446006.BXnWRvK5p3@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, peppe.cavallaro@st.com,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	devicetree <devicetree@vger.kernel.org>,
	roger.chen@rock-chips.com
To: =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446006.BXnWRvK5p3@phil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

2015-01-19 21:19 GMT+01:00 Heiko St=C3=BCbner <heiko@sntech.de>:
> Hi Romain
>
> Am Montag, 19. Januar 2015, 18:08:05 schrieb Romain Perier:
>> This series fixes few issues in dwmac-rk:
>>
>> 1. Voltage settings was hardcoded into the driver for the phy regula=
tor.
>>    The driver now uses the default voltage settings found in the dev=
icetree,
>> which are applied throught the regulator framework.
>> 2. The regulator name used to power on or power off the phy was put =
in the
>> devicetree variable "phy_regulator", which is not standard and added=
 a lot
>> of code for nothing. The driver now uses the devicetree property
>> "phy-supply" and the corresponding functions to manipulate this regu=
lator.
>>
>> The corresponding devicetree files are also updated. As, dwmac-rk wa=
s
>> recently pushed in the development tree, I don't care about devicetr=
ee
>> backward compatibility issues.
>
> This last sentence is slightly misleading :-) .
>

Yes, I meant that I don't need to care about it, as you explain it well=
 below.
Sorry for my misleading sentence ;) . I will fix it in my second serie.

> The actual fact is, that these new bindings for the rk3288 gmac have =
not been
> released with any official kernel release yet ... i.e. the will be re=
leased with
> 3.20 in whatever form, so we don't _need_ to care about keeping compa=
tibility
> still for the next 2.5 weeks or so.
>
> @Dave: it would be good if this series (when fixed) could still go in=
to the
> 3.20 material so we don't get stuck with the non-standard regulator p=
roperty.
>
>
> As we'll probably need a v2 due to at the issue in patch3, could you =
also
> switch places of patch1 and 2, which would keep bisecatbility (i.e. r=
egulator
> property before removing the voltage setting from the driver).

This sentence about re-ordering patches is for Dave or for me ?

Thanks,
Romain
