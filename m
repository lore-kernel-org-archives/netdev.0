From: Caesar Wang <caesar.upstream@gmail.com>
Subject: Re: [PATCH 0/6] arc_emac: fixes the emac issues oand cleanup emac
 drivers
Date: Fri, 11 Mar 2016 22:48:36 +0800
Message-ID: <56E2DAC4.4020105@gmail.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
 <56E2CC39.6050907@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caesar Wang <wxt@rock-chips.com>, Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Russell King <linux@arm.linux.org.uk>,
	Pawel Moll <pawel.moll@arm.com>,
	zhengxing <zhengxing@rock-chips.com>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	netdev@vger.kernel.org,
	Michael Turquette <mturquette@baylibre.com>,
	Kumar Gala <galak@codeaurora.org>,
	Stephen Boyd <sboyd@codeaurora.org>,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, keescook@google.com,
	Jiri Kosina <trivial@kernel.org>, linux-clk@vger.kernel.org,
	leozwang@google.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <56E2CC39.6050907@cogentembedded.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

=E5=9C=A8 2016=E5=B9=B403=E6=9C=8811=E6=97=A5 21:46, Sergei Shtylyov =E5=
=86=99=E9=81=93:
> Hello.
>
> On 3/11/2016 1:55 PM, Caesar Wang wrote:
>
>> This series patches are based on kernel 4.5-rc7+ version.
>> Linux version 4.5.0-rc7-next-20160310+ (wxt@nb) (...) #23 SMP Fri Ma=
r=20
>> 11 15:55:53
>
> [...]
>
>> 1) This series has 6 patches: (1--->6)
>> net: arc_emac: make the rockchip emac document more compatible
>> net: arc_emac: add phy-reset-* are optional for device tree
>
>    I'm not seeing these patches on netdev...

Sent by the patman tool.

LKML:
https://patchwork.kernel.org/patch/8564501/
https://patchwork.kernel.org/patch/8564511/

>
>> net: arc_emac: support the phy reset for emac driver
>> net: arc: trivial: cleanup the emac driver
>> clk: rockchip: rk3036: fix and add node id for emac clock
>> ARM: dts: rockchip: add support emac for RK3036
>>
>> 2) This series patches have the following decriptions:
>
>    Descriptions.
>
>> Hi Rob, David:
>> PATCH[1/6-2/6]: =3D=3D=3D=3D>
>> net: arc_emac: make the rockchip emac document more compatible
>> net: arc_emac: add phy-reset-* are optional for device tree
>>
>> The patches change the rockchip emac document for more compatible an=
d
>> Add the phy-reset-* property for document.
>>
>> This patch adds the following property for arc_emac.
>>
>> phy-reset-* include the following:
>> 1) phy-reset-gpios:
>> The phy-reset-gpios is an optional property for arc emac device tree=
=20
>> boot.
>> Change the binding document to match the driver code.
>>
>> 2) phy-reset-duration:
>> Different boards may require different phy reset duration. Add prope=
rty
>> phy-reset-duration for device tree probe, so that the boards that ne=
ed
>> a longer reset duration can specify it in their device tree.
>>
>> 3) phy-reset-active-high:
>> We need that for a custom hardware that needs the reverse reset=20
>> sequence.
>
>    Why not infer this from the "phy-reset-gpios" prop?

See:
https://patchwork.kernel.org/patch/8564511/

phy-reset-active-high : If present then the reset sequence using the GP=
IO
  specified in the "phy-reset-gpios" property is reversed (H=3Dreset st=
ate,
  L=3Doperation state).


Thanks,

Caesar

>
> MBR, Sergei
>
>
> _______________________________________________
> Linux-rockchip mailing list
> Linux-rockchip@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-rockchip

