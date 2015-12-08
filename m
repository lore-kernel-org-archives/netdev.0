From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 net-next 2/3] net: ethernet: cadence-macb: Add fallback
 to read DT provided caps
Date: Tue, 8 Dec 2015 17:22:52 +0100
Message-ID: <566703DC.1030501@atmel.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
 <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
 <1449582726-6148-3-git-send-email-narmstrong@baylibre.com>
 <2217940.QPNsks7uyL@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <harini.katakam@xilinx.com>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <joshc@ni.com>
To: Arnd Bergmann <arnd@arndb.de>,
	Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2217940.QPNsks7uyL@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 08/12/2015 16:00, Arnd Bergmann a =E9crit :
> On Tuesday 08 December 2015 14:52:05 Neil Armstrong wrote:
>> Add 1:1 mapping of software defines caps parsing from DT in case the
>> generic macb compatible form is used.
>> These properties will provide support for futures implementations
>> only defined from DT without need to update the driver code to suppo=
rt
>> new variants.
>>
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>>
>=20
> Translating the Linux implementation specific configuration into
> DT properties directly is usually not the best way.
>=20
> Could we instead have a lookup table by compatible string to set the
> flags? It seems that there are lots of different flags but only a
> couple of different users of this IP block. Also, the fact that
> you are now adding yet another quirk tells me that the set you
> define today is unlikely to cover all the future requirements.

This is basically what I told Neil in my previous email.

I understand you point Neil, but I don't find it makes sense and Arnd
described it better that I did.
So please find a proper compatibility string and simply use it. What
about:
"cdns,the_name_of_the_product_that_first_implemented_this_no_usrio_spec=
ial_case-gem"?

Bye,
--=20
Nicolas Ferre
