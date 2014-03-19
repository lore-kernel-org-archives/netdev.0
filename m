From: =?ISO-8859-1?Q?Emilio_L=F3pez?= <emilio@elopez.com.ar>
Subject: Re: stmmac-socfpga breakage in arm-soc
Date: Wed, 19 Mar 2014 13:47:38 -0300
Message-ID: <5329CA2A.8030309@elopez.com.ar>
References: <201403191333.01095.arnd@arndb.de> <4337501.shzGE38xmF@wuerfel> <5329AAE1.7030705@gmail.com> <29079107.ja9Hu9mMY0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dinh Nguyen <dinh.linux@gmail.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hans de Goede <hdegoede@redhat.com>, arm@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dinh Nguyen <dinguyen@altera.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <29079107.ja9Hu9mMY0@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

El 19/03/14 11:58, Arnd Bergmann escribi=F3:
(snip)
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Docum=
entation/devicetree/bindings/net/stmmac.txt
> index 5748351..19d5648 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -31,6 +31,10 @@ Optional properties:
>   - reset-names: Should contain the reset signal name "stmmaceth", if=
 a
>   	reset phandle is given
>   - max-frame-size: See ethernet.txt file in the same directory
> +- clocks: If present, the first clock should be the GMAC main clock,
> +  further clocks may be specified in derived bindings
> +- clock-names: One name for each entry in the clocks property, the
> +  first one should be "stmmaceth".
>
>   Examples:
>
> @@ -43,4 +47,6 @@ Examples:
>   		mac-address =3D [000000000000]; /* Filled in by U-Boot */
>   		max-frame-size =3D <3800>;
>   		phy-mode =3D "gmii";
> +		clocks =3D <&clock>;
> +		clock-names =3D "stmmaceth">

There's a small typo there on the ;

Cheers,

Emilio
