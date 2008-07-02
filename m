From: Mario Limonciello <mario_limonciello@dell.com>
Subject: Re: [PATCH] Setup PHYs for rtl8101/2(e) hardware
Date: Wed, 02 Jul 2008 16:58:03 -0500
Message-ID: <486BF9EB.3030405@dell.com>
References: <E6FF208A16840D4EBAA31D261B15A50601415DC7@ausx3mpc121.aus.amer.dell.com> <20080702215059.GA1378@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig959EF99CC835AB3750AD034D"
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:37407 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbYGBV6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 17:58:07 -0400
In-Reply-To: <20080702215059.GA1378@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig959EF99CC835AB3750AD034D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Francois:

r8101-1.008.05-1 was provided to me from a colleague who was working
with Realtek to support his platform.  It was given to me under the
presumption that it would have already been posted to the Realtek FTP by
now (I'm a bit surprised it isn't).

When you are warning of device overlap, I'm assuming you mean in the PHY
setup.  As of this r8101 release all of their configs in the driver
setup the PHYs the same way, so it didn't appear to be a problem.=20
You'll see once it is posted I suppose.

There is a number of other changes between the old release to this one,
but these were the only relevant changes that I saw to fix the current
transient stability issue of the device when loaded.

Edward:

Perhaps you can shed light as to why it hasn't been posted yet?

Regards,

Francois Romieu wrote:
> Mario_Limonciello@Dell.com <Mario_Limonciello@Dell.com> :
> [...]
>  =20
>> In comparing the differences with the Realtek release r8101-1.008.05-1=

>> of their r8101 driver, I found a handful of differences in  the startu=
p
>> procedures of the r8169 driver.  I isolated two sets of fixes that get=

>> rid of transient errors when loading the drivers.
>>    =20
>
> (please restrain your lines to ~80 cols and Cc: Edward)
>
> May I ask where did you got r8101-1.008.05-1 ? I only have
> r8101-1.007.00 from Realtek's ftp (dated 21/04/2008).
>
> Judging from r8101-1.007.00, I would say that your change is almost
> right but that it can overlap some existing devices. This remark may
> be irrelevant if there are enough differences between r8101-1.007.00
> and r8101-1.008.05-1 though.
>
>  =20

--=20
Mario Limonciello
*Dell | Linux Engineering*
mario_limonciello@dell.com


--------------enig959EF99CC835AB3750AD034D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIa/nr2CrZjkA73YsRAmEXAJ9LLTE51ekFLPSAc3xX2zuYt8nQHQCfbMy8
EGApLRhI8soBscma6hKRmac=
=a3IO
-----END PGP SIGNATURE-----

--------------enig959EF99CC835AB3750AD034D--
