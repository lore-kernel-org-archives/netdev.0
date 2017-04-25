From: Eric Anholt <eric@anholt.net>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the cygnus core DT.
Date: Mon, 24 Apr 2017 17:00:31 -0700
Message-ID: <8737cxe4ps.fsf@eliezer.anholt.net>
References: <20170424215022.30382-1-eric@anholt.net> <20170424215022.30382-3-eric@anholt.net> <20170424220842.GA26241@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anholt.net ([50.246.234.109]:38084 "EHLO anholt.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S979282AbdDYAAe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 20:00:34 -0400
In-Reply-To: <20170424220842.GA26241@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain

Andrew Lunn <andrew@lunn.ch> writes:

>> +		mdio: mdio@18002000 {
>> +			compatible = "brcm,iproc-mdio";
>> +			reg = <0x18002000 0x8>;
>> +			#size-cells = <1>;
>> +			#address-cells = <0>;
>> +
>> +			gphy0: eth-gphy@0 {
>> +				reg = <0>;
>> +				max-speed = <1000>;
>> +			};
>> +
>> +			gphy1: eth-gphy@1 {
>> +				reg = <1>;
>> +				max-speed = <1000>;
>> +			};
>> +		};
>
> Hi Eric
>
> Do these max-speed properties do anything useful? Is the PHY capable
> of > 1Gbps?

Not sure where I had those copy-and-pasted from, but they don't seem
necessary.  Dropped.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlj+kZ8ACgkQtdYpNtH8
nujsHBAAgms3IywzvhT2FsQkDMaFyL7gmZJv9h0f8wMpgFKN/zmjTBkCrYPNU4IF
lOazfhWs1pPcMSQnmRKjwL6R8oEwnzPuruQdH/USPeGF1tZuG5atGgBBGr0pbp+e
14xPFpN4RLZW8qUk9G5VNanc+9Yhm0zZwYayh/JOlhHvWc+Vw/S6TefOTeXus6j3
rJhvoiZNbC2kCCbFp2ht5fF/EEE6iH/JstMXDEKgNZE3a8Vxku3FpvL4dOnbMcV/
sVnwEtSOFpHPVydxT/qcfGHyJPllu5Ws13U3OwlT5M7ryi2ZaL0stV9Nn+Dw8KN/
zRJ4ZLgHMaSfBFnZCxbOD4S9cKRJLA58Hwrp9SWOB3QDgdo8mjTJUjAHt4IpDdN6
MT28vMsvaIdHTqlqKU19X7QPR7aSMnOxFW+O8wSbuIclKx79a1ThZsytrzOj2xXd
s5ci1BZaFyPpegp4rHueLxAr0+QM1xoQaxXzWwf5Ati5vraoJ8pROD4i6yOEJ3zr
hmvUaTUKzSv0gJGSpx4x5IHf0w7BTDnIxul97zHG3+OzZbPUKA3I8ZwkFTqYOHVk
KEUNYY5ovwSBcEFnwfGc0hlBB31ev15UlPEsMQOfnA+FnMrj6vTaC84c4KcOTdoS
V40C2EDLYRORh1rugs5Ija+CLxxfOBFj13W/C+7uNgDkHHwoL54=
=BAWs
-----END PGP SIGNATURE-----
--=-=-=--
