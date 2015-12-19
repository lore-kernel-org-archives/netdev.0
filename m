From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net/rfkill: Create "airplane mode" LED trigger
Date: Fri, 18 Dec 2015 21:25:37 -0500 (EST)
Message-ID: <20151218.212537.143932475051408734.davem@davemloft.net>
References: <1450193442-7930-1-git-send-email-jprvita@endlessm.com>
	<1450193442-7930-4-git-send-email-jprvita@endlessm.com>
	<20151219002212.GC7244@malice.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jprvita@gmail.com, johannes@sipsolutions.net,
	corentin.chary@gmail.com, platform-driver-x86@vger.kernel.org,
	acpi4asus-user@lists.sourceforge.net, jprvita@endlessm.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: dvhart@infradead.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <20151219002212.GC7244@malice.jf.intel.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Darren Hart <dvhart@infradead.org>
Date: Fri, 18 Dec 2015 16:22:12 -0800

> On Tue, Dec 15, 2015 at 10:30:41AM -0500, Jo=E3o Paulo Rechi Vita wro=
te:
>> For platform drivers to be able to correctly drive the "Airplane Mod=
e"
>> indicative LED there needs to be a RFKill LED trigger tied to the gl=
obal
>> state of RFKILL_TYPE_ALL (instead of to a specific RFKill) and that
>> works in an inverted manner of regular RFKill LED triggers, that is,=
 the
>> LED is ON when the state is blocked, and OFF otherwise.
>>=20
>> This commit implements such a trigger, which will be used by the
>> asus-wrc x86 platform driver.
>=20
> So this will need to go through Johannes and David per get_maintainer=
=2Epl before
> we can use it in platform drivers.
>=20
> +Johannes
> +David
> +wireless
> +netdev

RFKILL changes go via the wireless tree.
