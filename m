From: Valdis.Kletnieks@vt.edu
Subject: Re: [Web10g-user] Web10g TCP statistics patch - mainlining into kernel?
Date: Fri, 25 Jan 2013 14:56:24 -0500
Message-ID: <23149.1359143784@turing-police.cc.vt.edu>
References: <18855.1359138716@turing-police.cc.vt.edu>
            <5102DE61.80804@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1359143784_1992P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, web10g-user@web10g.org,
	linux-kernel@vger.kernel.org
To: rapier <rapier@psc.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Fri, 25 Jan 2013 14:34:57 -0500."
             <5102DE61.80804@psc.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1359143784_1992P
Content-Type: text/plain; charset=us-ascii

On Fri, 25 Jan 2013 14:34:57 -0500, rapier said:

> My name is Chris Rapier and I'm on the Web10G dev team. We are
> interested in moving this into consideration for the mainline Linux
> kernel, in fact it's the primary goal of this project. We haven't
> brought this to the linux kernel community as of yet as we've not
> completed the quantification of performance/memory impact versus a
> vanilla baseline as of yet.

I already looked over the patch and it looks *fairly* sane.  Having said
that, the best way to proceed for the performance side is probably to
get some rough ballpark numbers and then get the patch into a state
that's upstream-able before doing the final measurements (because there's
actually a high likelihood that the final numbers will end up being
dependent on the exact details of the patch, plus having more eyeballs on
it from the netdev side may shake out better approaches).

Sorry if you've already done all that - I didn't see much evidence of
it from the web10g-user archives...

--==_Exmh_1359143784_1992P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUQLjZwdmEQWDXROgAQL6uA//Xlo5ukYgPkGVHsOghQ0kohti2lgtK7rn
gJK5wYBBAbtSou71uf0wz7vwY5hmFnNNwG4hbGjHhkE5BsDOign0UF5STCd0i+bg
g4rYfVlw94GqDopjWr4tp9yT3TmGVNykTV/33cxFIq0uyPrE9PG4s5P/ItfzQ3XO
YkoMUb1Ww+Acr1t7tRNCymzgAZSzSWR4FOxbqg0r7u1xoKuxpRMRlSohZ7hopV5c
jX596z6OGGfF8VprESV1EtFTbgmSuHXhVnt3wQ+pX2UrTwsMBHSnWWDChJ+oSTC1
cDZ7T9ZJxmZcFuQZB8N5raBw3kH70PEnuVVpH6QGcLePtVZzSOOYtpiO5CGH6FrR
xBBhhoCmLRXbonnX9osf2pDAJK+MOXOzbTOvW22Xwj/E3iPpTPgoD3zQrYHPet9z
DoA7QN5i5Ql33PLwaLPc4m5X+JP8vn6AxqO9DHHDmWuROAL4kM85pHoTeEuJUoaS
0H/iTGBOr+keRaM9gH+8gZO/Fx+s9rKOhcJpt68UAqeG/R2IThDYCQGraSDga1cu
xs6kaSzQ6F/MHxye38aiCcRIJx2u6k6MA5sY1o+myhfBY4HHK4kJnS90iGsnw70O
l5qRkpJ7AWp3XgwC2FlfFaudgUF4AP71qj3UeZcqw7D7ZxiEivT9gzmI2R7n6evd
sZskFZVwuno=
=b4x0
-----END PGP SIGNATURE-----

--==_Exmh_1359143784_1992P--
