From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] ethtool: Macro definition for SFF-8436/8636
 Memory map max sizes
Date: Sun, 12 Jun 2016 13:33:04 +0100
Message-ID: <1465734784.3529.147.camel@decadent.org.uk>
References: <1465278926-10231-1-git-send-email-vidya@cumulusnetworks.com>
	 <20160611.155134.1474324006340328110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6d5SyBLMtfRjawu2gOeV"
Cc: bwh@kernel.org, netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, vidya@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33589 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932156AbcFLMdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 08:33:15 -0400
In-Reply-To: <20160611.155134.1474324006340328110.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6d5SyBLMtfRjawu2gOeV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2016-06-11 at 15:51 -0700, David Miller wrote:
[...]
> Why do we need these values in the header file at all?

Because we don't like putting magic numbers in driver code, and these
sizes are defined by standards that are independent of a single driver.

> The application can probe the size by repeated eeprom calls, increasing
> the buffer size each time as needed until success.

But really it should use ETHTOOL_GMODULEINFO first.

Ben.

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.

--=-6d5SyBLMtfRjawu2gOeV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXXVaAAAoJEOe/yOyVhhEJuIEQAJCVcE2eJ1O5LZYsInxr0A6M
PAZsEDcYvhjjCeOLEp59zvMUbuyV0b4krhpLrE6KYEgmG2isBOyjMsTEvQm+3pM2
Wx4QDsQBRE3AUVyufprNZP/M0g/3Bj036cCviiWhfHzshJON0E1Kz3rJ4MiHnWBf
yGMKZkqjQz3Mwi2LbSNL80a1SZzRG5ZDRRPmaxo9iBaI/CA7NtzDVC5rUS6vFNEK
/PmpfRRF0r4OgWHnFXoSmnVBFtllLdyJDCAS6cZZ00lJ4iMB+FZevawE1fvgM3ev
ctC4A76QmxUyxNtfGqRbO343xrWr56bHTuYgwouce4RF36DSwqdaQKJT1Abd2nr9
5kHKhdkQRctPkNnfKbTh46hZ5Fi0CZJW4AXnSU5FkQ9RQq4G67qqSJL7d2xVaxI0
komUkPn1yWYqlCBpJ1dbWHuPpCVn2qsBhLJ53FxP1i+AuMHrlvb7UCWkpCMn14Vs
zDgWX0vdmI9dsAu/B8LLI2G0mU5XRzOu/QTsvysCQafdj8CSySbPmqF8Vy9rRoQK
acEJBKTaxTX1CllD8BE6gyZ6ct6KuLIAof498gMCNfd2mlBrTbtLEAn0SpICn9aB
E1isw/wW5FyHIP2XqEhs8ZvNvm6Ub8uBMsot3lQ7d7F8lTzFyP1dm/2OhJ+F2UEm
lvCOr3adXRwILb8IUiHf
=I1Gp
-----END PGP SIGNATURE-----

--=-6d5SyBLMtfRjawu2gOeV--
