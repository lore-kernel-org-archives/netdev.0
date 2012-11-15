From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Thu, 15 Nov 2012 14:46:47 -0800
Message-ID: <50A570D7.3080409@gmail.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com> <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com> <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com> <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com> <CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com> <CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigFE88DE79A7F49BBC2197BD8A"
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: footplus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42226 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712Ab2KOWqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 17:46:51 -0500
In-Reply-To: <CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFE88DE79A7F49BBC2197BD8A
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/15/2012 01:36 PM, Aur=C3=A9lien wrote:
>> On Fri, Nov 9, 2012 at 4:08 PM, Ben Hutchings <bhutchings@solarflare.c=
om> wrote:
>>> No, the driver also needs to implement ethtool_ops::get_module_info a=
nd
>>> ethtool_ops::get_module_eeprom.  But those should be quite easy to do=
=2E
>>>
> Hi !
>
> I started to implement these operations in ixgbe.
>
> So far, the result is the attached patch, which applies on dave-m's
> net-next @ 1ff05fb7114a6b4118e0f7d89fed2659f7131b0a. It's not yet
> finished, and since it is my first peek at network drivers I need some
> advice on:
>
> - whether the implementation seems correct for ixgbe and all its
> supported MAC/PHY combinations ?
> - what would be the best way to manage SFF-8472 A0/A2 bank swapping
> mechanism for reading A2h ? (it seems I need to lock the whole -
> adress change sequence - read A2h - address change again - operation)
> in case it's needed. I may not be able to test that, so I may add an
> unsupported return code for now.
> - Is the supported PHY selection correct, or should other PHYs be
> supported ? What should be the rule ?
>
> I have been able to get correct temperature readings with a patched-up
> ethtool, so it seems to work correctly on at least my card (Ethernet
> controller [0200]: Intel Corporation 82599EB 10-Gigabit Network
> Connection [8086:10fb] (rev 01)).
>
> About ethtool, I was thinking about making a -O option for optical
> diagnostics, which would have a readable output. I will make a
> function to parse the A2 register contents, so it can be reused in
> other daemons/libs (SNMP, etc).
>
> Thanks,
> Best regards,
Can you please add me <jeffrey.t.kirsher@intel.com> to the CC on future
patches for ixgbe or ixgb, as I will be the one applying the patch to my
queue?

Thanks
Jeff


--------------enigFE88DE79A7F49BBC2197BD8A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iQIcBAEBCgAGBQJQpXDYAAoJEOVv75VaS+3OMqUP/29vkrH6ebLPRyck/HmXGwW8
o9KQMAQD84UvxPEQ5GOx9SAbZyEUI50oE7M6bvxXVUv9DlV+21hvzMYk+uynFu5p
ESzi+La7swEkxaPc/TSezgywe7zW//wvnnztUz6R2KXApEAga9Z/lrw1lJ9+oMBz
xRkUuTl69ivlHNfULAkGzJLEfu9ZuwR3alA3cgJTWtfK5eJZFnzRESwJif2/L717
hxJDyk8NZnJ/AuvQQKnLF0oRYN+dTCaHUtCjXZD3tfCPphS7L5uqMWHzB84sNvIY
qDMBj6MkYhNLRRvxAuo13j9jhQwR/697+b63nHmDVTkaD7dqV60XMxiZmFj7vXRm
VYxinPiStxG2XvwHyNXtZ1J2c7i/H8KnWLM0ORcrL+229xk4nEmXN2IDfkplYiJA
qfL4clTPWGRFRdQLT0YyPY9SZceXF0NSs8Ss7jL1VyWtrcSryB86b/vv6MTAytjm
HPtZG3b7VGJFCD+Ti1lnRoqMlwm3araWdu6smKPI83B+KroDKLyVIAr5dLRy7H2x
flemYRWCTodTzkrsje92V9P7kmKdzM2M+HPE8K7yyeyrZmthVFcjeIQX0xtllFxx
BvgTo2UsltE+30yEqXDzc1d3bnNY+E3Eqic+2kkxxxzAjMYNwRjiVYVPYif9kTFQ
eXw1Sjdv+IvoD/8hjzeR
=QoGt
-----END PGP SIGNATURE-----

--------------enigFE88DE79A7F49BBC2197BD8A--
