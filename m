From: Philip Prindeville <philipp@redfish-solutions.com>
Subject: Re: [PATCH net-next] net: ipv4: Add ability to have GRE ignore DF bit in IPv4 payloads
Date: Mon, 13 Jun 2016 12:59:31 -0600
Message-ID: <59274155-ED76-420B-A1F1-667DDCF6CB49@redfish-solutions.com>
References: <20160607194846.11494-1-philipp@redfish-solutions.com> <20160610.230202.897629473050684544.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_6C5F891A-3487-41E3-ABC4-8ADEFBA91C57"; protocol="application/pgp-signature"; micalg=pgp-sha512
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:39220 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423864AbcFMTFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 15:05:49 -0400
In-Reply-To: <20160610.230202.897629473050684544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_6C5F891A-3487-41E3-ABC4-8ADEFBA91C57
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii


> On Jun 11, 2016, at 12:02 AM, David Miller <davem@davemloft.net> wrote:
> 
> From: "Philip Prindeville" <philipp@redfish-solutions.com>
> Date: Tue,  7 Jun 2016 13:48:46 -0600
> 
>> From: Philip Prindeville <philipp@redfish-solutions.com>
>> 
>> In the presence of firewalls which improperly block ICMP Unreachable
>> (including Fragmentation Required) messages, Path MTU Discovery is
>> prevented from working.
>> 
>> A workaround is to handle IPv4 payloads opaquely, ignoring the DF bit--as
>> is done for other payloads like AppleTalk--and doing transparent
>> fragmentation and reassembly.
>> 
>> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
> 
> I think the feedback that this feature should be mutually exclusive
> to pmtudisc is valid and you should address that.

Yes, understood.  Looking into this.

-Philip


--Apple-Mail=_6C5F891A-3487-41E3-ABC4-8ADEFBA91C57
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJXXwKTAAoJEGTaZwSfpZInLJ8H/Aqh75RYumrRW4k4lMc89pwS
woWA1YNp42bDjZdSj4QlDbyqxvsfe+3LtVA/ZRTOyChVnTmAIhrZ/3inuVNbUsc8
cOUazwitABb7TZVIgEIAT183vNReUzHKJaH44JmBIac3m182WasTLMRPE/9cv9bS
InRariEmO2GBkvKkwIZ7EBv18tCSomb1QH4MjRrmDd8qcahkFtpQvwLDWcqe1HIy
ZxTMQP93+xTvenohUhrCf465T/xyJDZzjOd6h22EOpVgVWpOb8RHgUhGf5TRtfhm
OKq/22ACRefhWUv2ir68K3bmi4HFUfQkwd7eWO+hsi2Dp+lzYeeUF0Mb2Mh3NJs=
=iYmG
-----END PGP SIGNATURE-----

--Apple-Mail=_6C5F891A-3487-41E3-ABC4-8ADEFBA91C57--
