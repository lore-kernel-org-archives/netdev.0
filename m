From: boris brezillon <b.brezillon@overkiz.com>
Subject: Re: [PATCH v3 0/2] net/cadence/macb: add support for dt phy definition
Date: Tue, 27 Aug 2013 09:48:54 +0200
Message-ID: <521C59E6.2050000@overkiz.com>
References: <1377589007-3684-1-git-send-email-b.brezillon@overkiz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Boris BREZILLON <b.brezillon@overkiz.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377589007-3684-1-git-send-email-b.brezillon@overkiz.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

Sorry, I forgot to add your email in the cc list.

Do you want me to send you the whole series ?

Best Regards,

Boris

On 27/08/2013 09:36, Boris BREZILLON wrote:
> Hello,
>
> This patch series adds support for ethernet phy definition using device
> tree.
>
> This may help in moving some at91 boards to dt (some of them define an
> interrupt pin).
>
> Tested on samad31ek.
>
> Best Regards,
> Boris
>
> Changes since v2:
>   - fix wrong address of phy0 dt node
>
> Changes since v1:
>   - fix wrong macb_mii_init return code when no PHY device is discovered
>
> Boris BREZILLON (2):
>    net/cadence/macb: add support for dt phy definition
>    ARM: at91/dt: define phy available on sama5d3 mother board
>
>   arch/arm/boot/dts/sama5d3xmb.dtsi   |    8 ++++++
>   drivers/net/ethernet/cadence/macb.c |   48 +++++++++++++++++++++++++++--------
>   2 files changed, 46 insertions(+), 10 deletions(-)
>
