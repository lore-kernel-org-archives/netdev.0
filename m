From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH net-next v3 1/4] net: phy: add an option to disable EEE
 advertisement
Date: Mon, 28 Nov 2016 13:20:50 +0100
Message-ID: <34d6415d-aea9-6e92-cb3d-898ebe01202f@suse.de>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
 <1480326409-25419-2-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 Alexandre TORGUE <alexandre.torgue@st.com>, Andrew Lunn <andrew@lunn.ch>,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 Kevin Hilman <khilman@baylibre.com>, Neil Armstrong <narmstrong@baylibre.com>,
 linux-kernel@vger.kernel.org, Andre Roth <neolynx@gmail.com>,
 linux-amlogic@lists.infradead.org, Carlo Caione <carlo@caione.org>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 linux-arm-kernel@lists.infradead.org
To: Jerome Brunet <jbrunet@baylibre.com>, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1480326409-25419-2-git-send-email-jbrunet@baylibre.com>
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

Am 28.11.2016 um 10:46 schrieb Jerome Brunet:
> This patch adds an option to disable EEE advertisement in the generic PHY
> by providing a mask of prohibited modes corresponding to the value found =
in
> the MDIO_AN_EEE_ADV register.
> =

> On some platforms, PHY Low power idle seems to be causing issues, even
> breaking the link some cases. The patch provides a convenient way for the=
se
> platforms to disable EEE advertisement and work around the issue.
> =

> Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
> ---
>  drivers/net/phy/phy.c        |  3 ++
>  drivers/net/phy/phy_device.c | 80 ++++++++++++++++++++++++++++++++++++++=
+-----
>  include/linux/phy.h          |  3 ++
>  3 files changed, 77 insertions(+), 9 deletions(-)

Tested-by: Andreas F=E4rber <afaerber@suse.de>

With this and the corresponding .dts change, Odroid-C2 survived a
317-package zypper update for me.

Thanks,
Andreas

-- =

SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton
HRB 21284 (AG N=FCrnberg)
