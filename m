From: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH] net: macb: add phy-handle support for the macb
Date: Thu, 18 Aug 2016 15:53:55 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5E4438@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1471082509-11764-1-git-send-email-appanad@xilinx.com>
 <20160813.115222.443333178659469072.davem@davemloft.net>
 <C246CAC1457055469EF09E3A7AC4E11A4A5E27C6@XAP-PVEXMBX01.xlnx.xilinx.com>
 <20160816201436.GB3751@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org" <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        "sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org" <sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>,
        "gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org"
        <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        "narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org" <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160816201436.GB3751-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

	Thanks for the review...

>=20
> > Agree with you my intention is if there is a MDIO bus on the
> > device-tree The MAC driver should create PHY/MDIO devices using
> of_mdiobus_register().
>=20
> What you suggest is better, and is similar to what other drivers use.
>=20
> In order to keep backwards compatibility with phy nodes in the MAC node, =
you
> have to do of_mdiobus_register() with the MAC node. However, please chang=
e
> the binding documentation to say this is deprecated, all phy nodes should=
 be
> placed inside an mdio node.
>=20
> Using some better variable names would also help. mac_np and mdio_np for
> example.

Ok sure will post v2 as you suggested...

Regards,
Kedar.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
