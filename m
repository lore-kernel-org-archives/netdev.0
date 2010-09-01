From: Fleming Andy-AFLEMING <afleming@freescale.com>
Subject: Re: ERR_PTR pattern in phylib
Date: Wed, 1 Sep 2010 10:50:33 -0500
Message-ID: <15983BAD-0F31-4B58-B6C5-E2744F3A86D2@freescale.com>
References: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
Mime-Version: 1.0 (iPhone Mail 8A400)
Content-Type: multipart/mixed; boundary="===============3266086039366293616=="
Cc: netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

--===============3266086039366293616==
Content-Transfer-Encoding: 7bit
Content-Type: multipart/alternative; boundary="Apple-Mail-3-106355893";
	charset="iso-8859-1"

--Apple-Mail-3-106355893
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"



On Sep 1, 2010, at 9:43, Grant Likely <grant.likely@secretlab.ca> wrote:

>=20
> In the interest of making driver code easier to write and review,
> would you be opposed to a set of patches to remove the ERR_PTR()
> pattern from phylib and its users?


Not at all.  I was trying to make sure all the information was available, an=
d I'm not really a big fan of passing in a **ptr to get set.  But I don't re=
ally have a strong opinion.  This is just the design i settled on.  Heck, 99=
.9% of the errors are unlikely to ever happen, a they're caused by hardware m=
alfunction!

Andy


>=20
> g.
>=20
> --=20
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
>=20

--Apple-Mail-3-106355893
Content-Transfer-Encoding: base64
Content-Type: text/html; charset="utf-8"

PGh0bWw+PGJvZHkgYmdjb2xvcj0iI0ZGRkZGRiI+PGRpdj48YnI+PGJyPk9uIFNlcCAxLCAyMDEw
LCBhdCA5OjQzLCBHcmFudCBMaWtlbHkgJmx0OzxhIGhyZWY9Im1haWx0bzpncmFudC5saWtlbHlA
c2VjcmV0bGFiLmNhIj5ncmFudC5saWtlbHlAc2VjcmV0bGFiLmNhPC9hPiZndDsgd3JvdGU6PGJy
Pjxmb250IGNsYXNzPSJBcHBsZS1zdHlsZS1zcGFuIiBjb2xvcj0iIzAwMjNBMyI+PGZvbnQgY2xh
c3M9IkFwcGxlLXN0eWxlLXNwYW4iIGNvbG9yPSIjMDAwMDAwIj48YnI+PC9mb250PjwvZm9udD48
L2Rpdj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIj48ZGl2PjxzcGFuPjwvc3Bhbj48YnI+PHNwYW4+
SW4gdGhlIGludGVyZXN0IG9mIG1ha2luZyBkcml2ZXIgY29kZSBlYXNpZXIgdG8gd3JpdGUgYW5k
IHJldmlldyw8L3NwYW4+PGJyPjxzcGFuPndvdWxkIHlvdSBiZSBvcHBvc2VkIHRvIGEgc2V0IG9m
IHBhdGNoZXMgdG8gcmVtb3ZlIHRoZSBFUlJfUFRSKCk8L3NwYW4+PGJyPjxzcGFuPnBhdHRlcm4g
ZnJvbSBwaHlsaWIgYW5kIGl0cyB1c2Vycz88L3NwYW4+PGJyPjwvZGl2PjwvYmxvY2txdW90ZT48
ZGl2Pjxicj48L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2Pk5vdCBhdCBhbGwuICZuYnNwO0kgd2Fz
IHRyeWluZyB0byBtYWtlIHN1cmUgYWxsIHRoZSBpbmZvcm1hdGlvbiB3YXMgYXZhaWxhYmxlLCBh
bmQgSSdtIG5vdCByZWFsbHkgYSBiaWcgZmFuIG9mIHBhc3NpbmcgaW4gYSAqKnB0ciB0byBnZXQg
c2V0LiAmbmJzcDtCdXQgSSBkb24ndCByZWFsbHkgaGF2ZSBhIHN0cm9uZyBvcGluaW9uLiAmbmJz
cDtUaGlzIGlzIGp1c3QgdGhlIGRlc2lnbiBpIHNldHRsZWQgb24uICZuYnNwO0hlY2ssIDk5Ljkl
IG9mIHRoZSBlcnJvcnMgYXJlIHVubGlrZWx5IHRvIGV2ZXIgaGFwcGVuLCBhIHRoZXkncmUgY2F1
c2VkIGJ5IGhhcmR3YXJlIG1hbGZ1bmN0aW9uITwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+QW5k
eTwvZGl2PjxkaXY+PGJyPjwvZGl2Pjxicj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIj48ZGl2Pjxz
cGFuPjwvc3Bhbj48YnI+PHNwYW4+Zy48L3NwYW4+PGJyPjxzcGFuPjwvc3Bhbj48YnI+PHNwYW4+
LS0gPC9zcGFuPjxicj48c3Bhbj5HcmFudCBMaWtlbHksIEIuU2MuLCBQLkVuZy48L3NwYW4+PGJy
PjxzcGFuPlNlY3JldCBMYWIgVGVjaG5vbG9naWVzIEx0ZC48L3NwYW4+PGJyPjxzcGFuPjwvc3Bh
bj48YnI+PC9kaXY+PC9ibG9ja3F1b3RlPjwvYm9keT48L2h0bWw+
--Apple-Mail-3-106355893--

--===============3266086039366293616==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============3266086039366293616==--
