From: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH v2 2/2] ARM: dts: Add the ethernet and ethernet PHY to the cygnus core DT.
Date: Wed, 26 Apr 2017 10:26:44 -0700
Message-ID: <87r30fjd0r.fsf@eliezer.anholt.net>
References: <20170425235357.7690-1-eric@anholt.net> <20170425235357.7690-2-eric@anholt.net> <0cb00eb7-41d0-0390-4687-d966499ed9f4@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0cb00eb7-41d0-0390-4687-d966499ed9f4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 04/25/2017 04:53 PM, Eric Anholt wrote:
>> Cygnus has a single AMAC controller connected to the B53 switch with 2
>> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
>> the external ethernet jacks.
>>=20
>> Signed-off-by: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
>> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>=20
>> v2: Call the node "switch", just call the ports "port" (suggestions by
>>     Florian), drop max-speed on the phys (suggestion by Andrew Lunn),
>>     call the other nodes "ethernet" and "ethernet-phy" (suggestions by
>>     Sergei Shtylyov)
>>=20
>>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 58 +++++++++++++++++++++++++++=
+++++++
>>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>>  2 files changed, 66 insertions(+)
>>=20
>> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi b/arch/arm/boot/dts/bcm-c=
ygnus.dtsi
>> index 009f1346b817..9fd89be0f5e0 100644
>> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
>> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
>> @@ -142,6 +142,54 @@
>>  			interrupts =3D <0>;
>>  		};
>>=20=20
>> +		mdio: mdio@18002000 {
>> +			compatible =3D "brcm,iproc-mdio";
>> +			reg =3D <0x18002000 0x8>;
>> +			#size-cells =3D <1>;
>> +			#address-cells =3D <0>;
>
> Sorry for not noticing earlier, since you override this correctly in the
> board-level DTS file can you put a:
>
> 			status =3D "disabled"
>
> property in there by default?

Done.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlkA2FQACgkQtdYpNtH8
nuiG+RAAulmpDX7UD+c7qEvexcyuJLr7fZ5PPTXRXYmowA6JercWM3p3f+TQr/E8
wEGP6zDKR017Ov77ubuQdMyPaiXXbAlVsD788gcP7s6+B2DDn7w6UOIIu+4O+xrD
gt2a8ZbHnua9HCeupvTjHptU0e+459QV/1U9DNnF9xfF32dptEWx7/vK/cQfsOeC
3ODouOTXBOVSatFLyyyW1TDr8wvQ2uCNaDuhmtzmRjfYwM3u78aQk0dRjxBFAw36
oUHF2mHPeRuhu/USPs9qAa7gfSXkeVMwgTlKB3QzY/mNkCEt+p8mrhCw46Xa16yc
9WpkZg/U5bCUCdZDx79epYOFHAc7jJHX4Bs52zEmipivXTI+0ANT0E1KtXqPJjkd
xpqOj/bcKzhDNJ5azXygx7iqyefMdfcEecQ21FU25UbgW85V0/D/5DKVr5+gLuYX
P+F6bxxaOIicncbufiiEBpA6USepC+8h9CCfkMuClGRwM59FceNFTvvFDaJDn/1t
rP6a2uV39ui03WAEjYaVEK4N1g3jySv19f6j8x43aRo7v5em8g1lNJHU5ylMGGtD
kEoYvkBbh7lb8YL1PIqm7TT4dR/ai6g/JgjKs9f5zVo08Fdr3o8MJfNzQMRBUCFd
uOhxYLgzYuPjWtfV5xTfVk30Z7gEpngodJ9KyijZdHC/VkG9hX8=
=IcQ2
-----END PGP SIGNATURE-----
--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
