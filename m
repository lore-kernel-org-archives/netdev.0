From: Eric Anholt <eric@anholt.net>
Subject: Re: [PATCH v2 2/2] ARM: dts: Add the ethernet and ethernet PHY to the cygnus core DT.
Date: Wed, 26 Apr 2017 10:25:40 -0700
Message-ID: <87vaprjd2j.fsf@eliezer.anholt.net>
References: <20170425235357.7690-1-eric@anholt.net> <20170425235357.7690-2-eric@anholt.net> <20170426004907.GA9453@lunn.ch>
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
Received: from anholt.net ([50.246.234.109]:53840 "EHLO anholt.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752974AbdDZRZn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 13:25:43 -0400
In-Reply-To: <20170426004907.GA9453@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain

Andrew Lunn <andrew@lunn.ch> writes:

>> +		eth0: ethernet@18042000 {
>> +			compatible = "brcm,amac";
>> +			reg = <0x18042000 0x1000>,
>> +			      <0x18110000 0x1000>;
>> +			reg-names = "amac_base", "idm_base";
>> +			interrupts = <GIC_SPI 110 IRQ_TYPE_LEVEL_HIGH>;
>> +			max-speed = <1000>;
>
> Hi Eric
>
> Sorry i missed this the first time. Does this Ethernet controller do >
> 1Gbps? Does this max-speed do anything useful?

It doesn't look like it.  Dropped.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlkA2BQACgkQtdYpNtH8
nui2Cg/9HHWZyZl6ZyxmGCzJnCWmE2L0Xq05jK5uXFNdjHdrAXqzRva03jtPIXYd
lX0FyvfiwQgYGVr71p6QZr1CNW/v82Ob9IyBn6YMVyxyRZNWG/nIpjeKULq5yCFD
7klP3V17XiA2j1eQFZpjNaDEj9IKeYJQfvMFnCvpyqpk+Ef5wlC1rawqv9j1x6ob
Gj6VsSoJFMoksdRLHT8u5uy3eo+HoBQnugbqNeqjkJvidkNyMg4ElCQMnZj9vngs
D8l82v6QM96qCl5LU9e7Bn3hUzIVJxiJWwkmIyFUHdW4sXce71LKwFvNa8362dmE
F+FpKumTO6PeV2uC1URt8zieig+GjMAcM0N2+zA1ge7aLVhOHlw3mVycdY9FEgW9
ejP2yqn+3JMa58UU1BZQQ490QkABp6nnqHLzuBBphHfTM1THK1YwZeichH1NpZvo
BlnXa7+PimnfJrFDkz0b2FkC0O3SzlsvsRql0/yYoMFoBQW15c996J5GqQ+FuKBV
Ij/hzLCK2upDR7Pky9fLdwZDMlt0NkBHLphU9PmUFpRnP+3Qq0/3T1EFMIuptq4o
iXOGZ/QFhfIjBzAajNz41sHTWy7x75sToKYS3yUF6/ClD7S4qRzK1VpHIdh+WtWf
t+YsxqDkFRZ7QkmHy7qyN3K49dRjwG3gO/2+MEcQAj69dRPTR3s=
=WuFm
-----END PGP SIGNATURE-----
--=-=-=--
