From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 2/7] ixgbe: Indicate removal state explicitly
Date: Thu, 9 Jan 2014 17:29:29 +0000
Message-ID: <7F0D3A98-29B4-4153-B720-0CDAD7EC8C0B@intel.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
 <1389166847-3780-3-git-send-email-aaron.f.brown@intel.com>
 <79DAF37B-9AA5-407B-81D2-3EDFD8589254@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_823E2992-C9F6-4C36-893B-E68DCDE4AFA2";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55571 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbaAIR3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 12:29:31 -0500
In-Reply-To: <79DAF37B-9AA5-407B-81D2-3EDFD8589254@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_823E2992-C9F6-4C36-893B-E68DCDE4AFA2
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jan 8, 2014, at 12:37 AM, Scott Feldman <sfeldma@gmail.com> wrote:

>=20
> On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> =
wrote:
>=20
>> From: Mark Rustad <mark.d.rustad@intel.com>
>>=20
>> Add a bit, __IXGBE_REMOVE, to indicate that the module is being
>> removed. The __IXGBE_DOWN bit had been overloaded for this purpose,
>> but that leads to trouble. A few places now check both __IXGBE_DOWN
>> and __IXGBE_REMOVE. Notably, setting either bit will prevent service
>> task execution.
>>=20
>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
>> ---
>> drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 ++++++++----
>> 2 files changed, 9 insertions(+), 4 deletions(-)
>>=20
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h =
b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> index 49531cd..8da263a 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> @@ -798,6 +798,7 @@ enum ixgbe_state_t {
>> 	__IXGBE_TESTING,
>> 	__IXGBE_RESETTING,
>> 	__IXGBE_DOWN,
>> +	__IXGBE_REMOVE,
>=20
> __IXGBE_REMOVING?  More consistent with _TESTING, _RESETTING, etc.

And more correct in actual meaning as well. Another good suggestion.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_823E2992-C9F6-4C36-893B-E68DCDE4AFA2
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSztx5AAoJEDwO/+eO4+5uzjgP/2/QjqviQ0GhKltkaRBdEQN/
uljQ13fb/nU+hgiOP35KUM9L+tBpil7FPLjJhKvpx8AX+QUWEsKWGLmy8Wz/TqCc
Mg+eONnm042ZEh3P++zXVVZJoMaw+d9IXxOhZTCbqkEz5qqdQuUvSqatTHy0eRAb
quy8fqmdAvrwK5xb4qwk8YTi2pD3x3oTTn0CCgn+uCbVsOsL7zju1YNHvzWFFd8x
q+Bp1l7zStYYltLDMMzSpfoFvGSHuxrX6MBuTtAcL/95ZZzpL7AsA2Fn5pBcqUPf
Ak5mikvrsznRUJj33TfaHh3hdC1kdVAkh2UsP+uXQoIOL9FlvXmF3UKdoBdL/DBS
SwPS+a9gZ6ZZFKfiZMq5TMqOP3vpHwDdN5pmKIPdbKGe7KCew93W2UqevdLRA1Vb
KyGCjD0KUUlVAkllfJJXXukgQ08cGSdp2awm+bVEiLrGyxW4/I61nFYhcAuRl8un
uqZi+IJyYcpUuBrUlCFxC2xasMtOAIUI7MGIWMat0Xa1Nwl7rF+rFtdBojxM1tGh
20wFkEff4fL6lAU0UcrDtj/GZCo71E+SxM+SeI0QzgQ0vJIKvarHpsTf/Vq7H4U3
O2cHz+OCRuh+w3p7Fyd5iJcWQRsVekRvjW+3x49rOLW5AVn/XgWJn2zXOND8whan
V1TkSVM9LIgjOjnrYqtf
=Elfu
-----END PGP SIGNATURE-----

--Apple-Mail=_823E2992-C9F6-4C36-893B-E68DCDE4AFA2--
