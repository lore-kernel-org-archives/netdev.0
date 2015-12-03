From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 13/15] ixgbe: Handle extended IPv6 headers in tx path
Date: Thu, 3 Dec 2015 01:06:34 +0000
Message-ID: <BDE75CB1-7061-4841-A2B7-B4C39A3F03C1@intel.com>
References: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1449059468-87025-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <565F1A6E.5010305@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_FFF015B6-3D23-4938-B5CE-5695C344758F";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:11026 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754717AbbLCBGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 20:06:36 -0500
In-Reply-To: <565F1A6E.5010305@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_FFF015B6-3D23-4938-B5CE-5695C344758F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

Alexander Duyck <alexander.duyck@gmail.com> wrote:

> This doesn't look right.  How come this doesn't match the =
implementation you did for the ixgbevf driver?  If I am not mistaken =
this approach had issues where it could spin forever didn't it?

Yes, this is the original version of the patch instead of the V4 of the =
patch which you would recognize and should have seen on the =
intel-wired-lan list. Jeff and I discussed this a little while ago and I =
sent him a link to the V4 of the patch in patchwork.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_FFF015B6-3D23-4938-B5CE-5695C344758F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWX5WaAAoJEDwO/+eO4+5u2NYP/324092VtCawAe5eUM7/G0wQ
/+hX/QwoqkridFhXLk3v8KWrsF4TVqp0+ay2if74sJ5YM5r0VS+5N/E1V4gtVScx
YSl2UWlp6MVDSdQTlr3Q3f1VYzfDIdFW+taCPY+V1bpTS6rCdxT/7qgisLOqqun1
N70IDMAjt6b5MVhHJ2IRPKLpRM+H0LpNQy9l0ZFCMFXmdVGMegbTDlZ+j8EtazeA
eiDMqfU3bcK2OHMXzIgbr+dcGI7cZLGH27uXYeXYssfAqDEI5Or7EFImaMquT5k6
wt25EZxQR4U9Llp1Q4tBHNZVwfRQtbtR7ky/8p9cNhPMq82DXhY+DWkdnF5pyWhP
tM+ChgBhN7LwwIyRFevaWLvo6VWxJynblM7cqPoUSmPGOIGUSdmnXSYO6tnGtsyS
915/ZoykNbI4k1h1b4SnGjmJx62uz76LUOhnXU5D2+3s2A+HZBoBqSuIEMP0krT3
FxdD9EOPj0D0+DSxWqYmZ1iOOaSCbaO2DdZ4iLptTsDIOJN5TuzK8UYHabMtgTJs
bAEiH7eHcyfBnE5Mj+AKiTZIlTz/a5+ZBSVGvsD3TpKnv1q/9pp6Zym5gCBc58Vz
iCYXjW29PlZtMicOvJ9C/baPcXD2TsCR89EPvKv1bjx74ulm0NRcEyODVKtvuwys
zC5LYWnGzI5NGhFkhZJZ
=9qHt
-----END PGP SIGNATURE-----

--Apple-Mail=_FFF015B6-3D23-4938-B5CE-5695C344758F--
