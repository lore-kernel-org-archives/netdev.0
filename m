From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: State of the Union: Wireless
Date: Fri, 06 Jan 2006 13:26:24 +0100
Message-ID: <1136550384.4037.48.camel@localhost>
References: <20060106042218.GA18974@havoc.gtf.org>
	 <1136547084.4037.41.camel@localhost>
	 <20060106114620.GA23707@isilmar.linta.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pn4ZYF1I2OiS/FpE2WQN"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751420AbWAFM0d@vger.kernel.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
In-Reply-To: <20060106114620.GA23707@isilmar.linta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-pn4ZYF1I2OiS/FpE2WQN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> From someone who has no idea at all (yet) about 802.11: why character
> device, and not sysfs or configfs files? Like

As Michael already said -- there's no real reason for that. We were just
brainstorming. The /dev idea seemed like a good plan at first, but then
it isn't fixed. What you suggested below does look useful too.

Coming back to the point Michael already raised: the overarching idea is
to get rid of the net_dev for the 'master' device, even if the
underlying hardware supports only a single virtual device (which might
then be created by the driver automatically)

I'll move the wiki pages a bit to accomodate different models, please
check in a few minutes.

johannes

--=-pn4ZYF1I2OiS/FpE2WQN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (SIP Solutions)

iQIVAwUAQ75h7qVg1VMiehFYAQJ9hRAAhS1iOJEYYhn1Mcm/D0N2EkAH99y7A3Fl
DJw0+37syAHVeyti+jntkCWVG1WEkawe6wMeh77deumRTc3fgonlTVKXRIpgVUMJ
lPbKpblVaSQrq26cjupuSBRCS5Hu6R2Lj2kFWrilGH9aa311G9Zs60I4rPlf8GG3
cETYSP8CsizXY17mrn+OUAHOT6fg2BOwJDsownEzI39vdYIc2JX/L6VD+uPkf1L9
Hn/Ga+qiZxG0wgWiHV883h4XLAOwwoHtnTk/iu/ONUss7PYaO9SMf+fJqUel1SFd
b5i2xQbKrWhWSIiUdNsPA1LPQhTAIcLrovEaiEVSV7uOtDsG5dPCszju2zDBRSAm
d5ZqUx3DDDzUcPwH0lpDNXFwvhVgNSCNZqv4qTiPH4PClEBqci4Lrs4DMzZFiTU1
btPEaJ2o7Zrw8y0QrIrd7RIvwGgin8M8Jz67Qv4M5CA8DEyTJZvSKCQcYQb1MweY
ovUTgmzgQN4GWFVvJsmbLFoKGuaTtRw9qRTX1d4R0eCSLA4pFV+xu3RagXQ/WzOL
VSPRSujxvuxQRqzWZlHM9R88j/ImSxKW5mk0MXGacUP8kPdT39XHG+IvYnQ3URvZ
wYUQa3cYUoiQ0qF9crxoS0Akn7P7xUf7j2hz341mw2kNfJpm3xjoXCTdM9KMIJkV
NYFId+sZJeU=
=ZGau
-----END PGP SIGNATURE-----

--=-pn4ZYF1I2OiS/FpE2WQN--
