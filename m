From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH net-next v3 2/4] dt-bindings: net: add EEE capability
 constants
Date: Mon, 28 Nov 2016 11:28:33 +0100
Message-ID: <CAGm1_kujHF_+==4A5h_QaEczEA+xmh6DnRRDMkNEmWtdaNNapQ@mail.gmail.com>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
 <1480326409-25419-3-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 Alexandre TORGUE <alexandre.torgue@st.com>, Andrew Lunn <andrew@lunn.ch>,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 netdev <netdev@vger.kernel.org>, Neil Armstrong <narmstrong@baylibre.com>,
 kernel list <linux-kernel@vger.kernel.org>, Andre Roth <neolynx@gmail.com>,
 Kevin Hilman <khilman@baylibre.com>, Carlo Caione <carlo@caione.org>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>, linux-amlogic@lists.infradead.org,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1480326409-25419-3-git-send-email-jbrunet@baylibre.com>
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

On Mon, Nov 28, 2016 at 10:46 AM, Jerome Brunet <jbrunet@baylibre.com> wrote:
> Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>

Tested using Baltos ir2110 device (cpsw + at8035 PHY).

Tested-by: Yegor Yefremov <yegorslists@googlemail.com>

> ---
>  include/dt-bindings/net/mdio.h | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>  create mode 100644 include/dt-bindings/net/mdio.h
>
> diff --git a/include/dt-bindings/net/mdio.h b/include/dt-bindings/net/mdio.h
> new file mode 100644
> index 000000000000..99c6d903d439
> --- /dev/null
> +++ b/include/dt-bindings/net/mdio.h
> @@ -0,0 +1,19 @@
> +/*
> + * This header provides generic constants for ethernet MDIO bindings
> + */
> +
> +#ifndef _DT_BINDINGS_NET_MDIO_H
> +#define _DT_BINDINGS_NET_MDIO_H
> +
> +/*
> + * EEE capability Advertisement
> + */
> +
> +#define MDIO_EEE_100TX         0x0002  /* 100TX EEE cap */
> +#define MDIO_EEE_1000T         0x0004  /* 1000T EEE cap */
> +#define MDIO_EEE_10GT          0x0008  /* 10GT EEE cap */
> +#define MDIO_EEE_1000KX                0x0010  /* 1000KX EEE cap */
> +#define MDIO_EEE_10GKX4                0x0020  /* 10G KX4 EEE cap */
> +#define MDIO_EEE_10GKR         0x0040  /* 10G KR EEE cap */
> +
> +#endif
> --
> 2.7.4
>
