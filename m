From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless: recap of current issues (stack)
Date: Fri, 13 Jan 2006 23:34:26 +0100
Message-ID: <1137191666.2520.68.camel@localhost>
References: <20060113195723.GB16166@tuxdriver.com>
	 <20060113212605.GD16166@tuxdriver.com>
	 <20060113213200.GG16166@tuxdriver.com>
	 <20060113222259.GL16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oeYItp24XItWk5FtuXNC"
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423050AbWAMWed@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <20060113222259.GL16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oeYItp24XItWk5FtuXNC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-01-13 at 17:22 -0500, John W. Linville wrote:

> Can the in-kernel stack be saved?  With the addition of softmac?
> Is it possible to extend softmac to support virtual wlan devices?
> If not, how do we proceed?

Well, softmac doesn't really have too many issues [that make it
incompatible with the planned stuff, that is]. Right now it layers
above ieee80211_device, and it would continue doing so, with
ieee80211_device transformed into the representation of the virtual STA
device.

johannes

--=-oeYItp24XItWk5FtuXNC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (SIP Solutions)

iQIVAwUAQ8gq8KVg1VMiehFYAQK90g//fPYGUY/R+NX44VIo1APZkgVdrfH0q5Zg
93FOogfIEjQgPydjLDqDn46ZVbhppOWpnYbE7uZfIcRLwl0PQjr85SOwKxkV134E
DWHRD5th3iUTvPYr0LcQuwDbKHh5doIup2VCqr5Evvb4Fp7cpe8rb5Qi9ycnW8cS
iPYE8eLMP0FZaaxTWLkanFhmf1ZOH6C7AOwuhJqZDxVMuGWipsbyOfeH93UZit7O
xa/H7OXZUGrl9Kli7viHS5QB6kG6JX9fwKRxALZGoqPvinpDFlGvjAdW63dNHMWa
kOs5o0GAgo7Rpy2802Q8N3ednwuyi4MrtHBZWWxrMWZXm7eKs3P7VIFecvT8xUU3
Pn4wMHVgqUcyx+NPwNU22y1TpXFrwPM+YT9vyng7ZuT00NYU8HN1fCihwUkU21QA
MZYzgoVD3yH2/CT8hTlpzEErO6mNrqtaLwNHKGaAwJvmKWgR7qqdo/QoumZ6JLMU
AkRZ8ImmkmvhMJn26kCk5hWBJermTKz3viP57IwWQcVrTOKCLjIFMfzIUjxtH03W
68Zfs1mCa8Q3D9nRL+V+5D9GrOV/ZaHAPqPTrbzFE6LiO8+2N0Sh266Y/zeM/EZm
cHHm0jsFxanhuCs+3eWUdUxZCUMYXImmKlnib/sGvL9PAGGDKua97DIAGrFBmUX9
OFbYobr89OI=
=qW9h
-----END PGP SIGNATURE-----

--=-oeYItp24XItWk5FtuXNC--
