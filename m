From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/6] arc_emac: fixes the emac issues oand cleanup emac
 drivers
Date: Fri, 11 Mar 2016 21:46:04 +0300
Message-ID: <56E3126C.7000100@cogentembedded.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
 <56E2CC39.6050907@cogentembedded.com> <56E2DAC4.4020105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Caesar Wang <caesar.upstream@gmail.com>
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <56E2DAC4.4020105@gmail.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/11/2016 05:48 PM, Caesar Wang wrote:

[...]

>>> Hi Rob, David:
>>> PATCH[1/6-2/6]: ====>
>>> net: arc_emac: make the rockchip emac document more compatible
>>> net: arc_emac: add phy-reset-* are optional for device tree
>>>
>>> The patches change the rockchip emac document for more compatible and
>>> Add the phy-reset-* property for document.
>>>
>>> This patch adds the following property for arc_emac.
>>>
>>> phy-reset-* include the following:
>>> 1) phy-reset-gpios:
>>> The phy-reset-gpios is an optional property for arc emac device tree boot.
>>> Change the binding document to match the driver code.
>>>
>>> 2) phy-reset-duration:
>>> Different boards may require different phy reset duration. Add property
>>> phy-reset-duration for device tree probe, so that the boards that need
>>> a longer reset duration can specify it in their device tree.
>>>
>>> 3) phy-reset-active-high:
>>> We need that for a custom hardware that needs the reverse reset sequence.
>>
>>    Why not infer this from the "phy-reset-gpios" prop?
>
> See:
> https://patchwork.kernel.org/patch/8564511/
 >
> phy-reset-active-high : If present then the reset sequence using the GPIO
>   specified in the "phy-reset-gpios" property is reversed (H=reset state,
>   L=operation state).

    Referring to your own suggested bindings isn't an answer. If the driver 
that you're copying from here (fec) had a reason to handle the GPIO sense with 
the help of an extra prop (legacy code), it doesn't mean your new driver needs 
to mimic this as well, AFAIU...

> Thanks,
>
> Caesar

MBR, Sergei

