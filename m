From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Mon, 7 Mar 2016 09:08:21 +0100
Message-ID: <56DD36F5.2000308@pengutronix.de>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56DC1561.9060306@hartkopp.net>
 <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="DiPGUdcEabqT1Q94haPPxF80Lo3ThWM4J"
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DiPGUdcEabqT1Q94haPPxF80Lo3ThWM4J
Content-Type: multipart/mixed; boundary="qxKHJv4xXsPHVksRX028wLFepJ2VPePO6"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>,
 "wg@grandegger.com" <wg@grandegger.com>,
 "robh+dt@kernel.org" <robh+dt@kernel.org>,
 "pawel.moll@arm.com" <pawel.moll@arm.com>,
 "mark.rutland@arm.com" <mark.rutland@arm.com>,
 "ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
 "galak@codeaurora.org" <galak@codeaurora.org>,
 "corbet@lwn.net" <corbet@lwn.net>
Cc: "linux-renesas-soc@vger.kernel.org" <linux-renesas-soc@vger.kernel.org>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 "geert+renesas@glider.be" <geert+renesas@glider.be>,
 Chris Paterson <Chris.Paterson2@renesas.com>
Message-ID: <56DD36F5.2000308@pengutronix.de>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56DC1561.9060306@hartkopp.net>
 <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
In-Reply-To: <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>

--qxKHJv4xXsPHVksRX028wLFepJ2VPePO6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/07/2016 09:02 AM, Ramesh Shanmugasundaram wrote:
> Hi Oliver,
>=20
> Thanks for the review comments.
>=20
>> On 03/03/2016 04:38 PM, Ramesh Shanmugasundaram wrote:
>>
>>> Changes since v1:
>>> 	* Removed testmodes & debugfs code (suggested by Oliver H)
>>> 	* Fixed tx path race issue by introducing lock (suggested by Marc K)=

>>> 	* Removed __maybe_unused attribute of rcar_canfd_of_table
>>>
>>
>>
>>>  obj-$(CONFIG_CAN_M_CAN)		+=3D m_can/
>>>  obj-$(CONFIG_CAN_RCAR)		+=3D rcar_can.o
>>> +obj-$(CONFIG_CANFD_RCAR)	+=3D rcar_canfd.o
>>
>> Just for the sake of an ordered directory structure:
>>
>> Would it make sense to create a rcar directory where rcar_can.c and
>> rcar_canfd.c are placed?
>>
> Yes. I'll place them in rcar dir.
>=20
>> Additionally (besides of one accident with the obsolete PCH_CAN) all C=
AN
>> drivers start with CONFIG_CAN_...
>>
>> Following that scheme the config option should be named
>>
>> 	CONFIG_CAN_RCAR_CANFD
>>
>> as we had in CONFIG_CAN_IFI_CANFD.
>=20
> Agreed.
>=20
>>
>>>  obj-$(CONFIG_CAN_SJA1000)	+=3D sja1000/
>>>  obj-$(CONFIG_CAN_SUN4I)		+=3D sun4i_can.o
>>>  obj-$(CONFIG_CAN_TI_HECC)	+=3D ti_hecc.o
>>> diff --git a/drivers/net/can/rcar_canfd.c
>>> b/drivers/net/can/rcar_canfd.c
>>
>> (..)
>>
>>> +/* Channel priv data */
>>> +struct rcar_canfd_channel {
>>> +	struct can_priv can;			/* Must be the first member */
>>> +	struct net_device *ndev;
>>> +	struct rcar_canfd_global *gpriv;	/* Controller reference */
>>> +	void __iomem *base;			/* Register base address */
>>> +#ifdef CONFIG_DEBUG_FS
>>> +	struct dentry *dev_root;
>>> +#endif /* CONFIG_DEBUG_FS */
>>
>> Some missed stuff from debugfs removal?
>=20
> :-(. Sorry. Will clean up.
>=20
>>
>>> +	struct napi_struct napi;
>>> +	u8  tx_len[RCANFD_FIFO_DEPTH];		/* For net stats */
>>> +	u32 tx_head;				/* Incremented on xmit */
>>> +	u32 tx_tail;				/* Incremented on xmit done */
>>> +	u32 channel;				/* Channel number */
>>> +	spinlock_t tx_lock;			/* To protect tx path */
>>> +};
>>
>> (..)
>>
>>> +static int rcar_canfd_start(struct net_device *ndev) {
>>> +	struct rcar_canfd_channel *priv =3D netdev_priv(ndev);
>>> +	int err =3D -EOPNOTSUPP;
>>> +	u32 sts, ch =3D priv->channel;
>>> +	u32 ridx =3D ch + RCANFD_RFFIFO_IDX;
>>> +
>>> +	/* Ensure channel starts in FD mode */
>>> +	if (!(priv->can.ctrlmode & CAN_CTRLMODE_FD)) {
>>> +		netdev_err(ndev, "enable can fd mode for channel %d\n", ch);
>>> +		goto fail_mode;
>>> +	}
>>
>> What's the reason behind this check?
>>
>> A CAN FD capable CAN controller can be either configured to run as CAN=
 2.0
>> (Classic CAN) or as CAN FD controller.
>>
>> So why are to throwing an error here and produce an initialization
>> failure?
>=20
> When this controller is configured in FD mode and used only with CAN 2.=
0 nodes, it still expects a DTSEG (data bitrate) configuration same as NT=
SEG (nominal bitrate). This check, specifically in ndo_open, ensures both=
 are configured and will work fine with CAN 2.0 nodes (e.g.)
>=20
> "ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on"
>=20
> If I don't have this check, a configuration like this
>=20
> "ip link set can0 up type can bitrate 1000000"
>=20
> will bring up the controller without DTSEG configured.=20

That should bring up the controller in CAN 2.0 mode.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--qxKHJv4xXsPHVksRX028wLFepJ2VPePO6--

--DiPGUdcEabqT1Q94haPPxF80Lo3ThWM4J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJW3Tb1AAoJED07qiWsqSVq6IQH/iJ6g7txb5Du+MWa0Hl3YqOm
TcdO2b4PDaMN3RfzpmX385LZcwJetSIHeZDEI2hfMb2zykY4Gg992wluKUErvROR
+fYI6SBe2ifRMskqyoZ82+rrIr6ZdhWKaAP/i9REcLs1APFCh4BQHxPp47BEwfLW
hpZ+7R8lTX8NaQeS6MY6JZG5Ct2HqpQAupgFncqMpR2kGVNbHohtL3BtthXNG63i
jQGeF9rDhlyi9W+LVD8MolyIc3llqwEjM0z5pygTmpum8dibwb1ARLVuaGxlC1ll
8liSH3vVXRKe7vYrxPw02WxFN93iH/DC6zwwPxSNDStMkFwVidH0gSaa2TljfaM=
=Xb2s
-----END PGP SIGNATURE-----

--DiPGUdcEabqT1Q94haPPxF80Lo3ThWM4J--
