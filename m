From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 25 Sep 2004 01:30:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925013036.76586445.davem@davemloft.net>
References: <20040925064406.GL3236@sunbeam.de.gnumonks.org>
	<20040925005623.2faf8faf.davem@davemloft.net>
	<20040925.171412.75484376.yoshfuji@linux-ipv6.org>
	<20040925.172712.30172597.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Sat__25_Sep_2004_01_30_36_-0700_fNjW+ilCHUf_yLSs"
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040925.172712.30172597.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Sat__25_Sep_2004_01_30_36_-0700_fNjW+ilCHUf_yLSs
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Sat, 25 Sep 2004 17:27:12 +0900 (JST)
YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B <yoshfuji@linux-ipv6.org> wrote:

> In article <20040925.171412.75484376.yoshfuji@linux-ipv6.org> (at Sat, 25=
 Sep 2004 17:14:12 +0900 (JST)), YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B <yo=
shfuji@linux-ipv6.org> says:
>=20
> > In article <20040925005623.2faf8faf.davem@davemloft.net> (at Sat, 25 Se=
p 2004 00:56:23 -0700), "David S. Miller" <davem@davemloft.net> says:
> >=20
> >=20
> > > +			if (n->nud_state -=3D NUD_INCOMPLETE &&
> >=20
> > I guess this is typo of:
> > 			if (n->nud_state =3D=3D NUD_INCOMPLETE &&
> >=20
> > Am I wrong?
>=20
> Sorry, I forgot to state the source; this lives in diff4.

Good catch, you are correct.

Fixed version attached.

--Multipart=_Sat__25_Sep_2004_01_30_36_-0700_fNjW+ilCHUf_yLSs
Content-Type: application/octet-stream;
 name="diff4"
Content-Disposition: attachment;
 filename="diff4"
Content-Transfer-Encoding: base64

PT09PT0gbmV0L2NvcmUvbmVpZ2hib3VyLmMgMS40NyB2cyBlZGl0ZWQgPT09PT0KLS0tIDEuNDcv
bmV0L2NvcmUvbmVpZ2hib3VyLmMJMjAwNC0wOS0yNCAxNjoyMTo0OSAtMDc6MDAKKysrIGVkaXRl
ZC9uZXQvY29yZS9uZWlnaGJvdXIuYwkyMDA0LTA5LTI1IDAxOjExOjQ3IC0wNzowMApAQCAtMTEw
LDEzICsxMTAsMTMgQEAKIAlyZXR1cm4gKG5ldF9yYW5kb20oKSAlIGJhc2UpICsgKGJhc2UgPj4g
MSk7CiB9CiAKLQotc3RhdGljIGludCBuZWlnaF9mb3JjZWRfZ2Moc3RydWN0IG5laWdoX3RhYmxl
ICp0YmwpCitzdGF0aWMgaW50IG5laWdoX2ZvcmNlZF9nYyhzdHJ1Y3QgbmVpZ2hfdGFibGUgKnRi
bCwgaW50IGdvYWwpCiB7Ci0JaW50IHNocnVuayA9IDA7CisJaW50IHNocnVuayA9IDAsIG51bV9p
bmNvbXBsZXRlID0gMCwgcmVhcF9pbmNvbXBsZXRlID0gMDsKIAlpbnQgaTsKIAogCXdyaXRlX2xv
Y2tfYmgoJnRibC0+bG9jayk7CityZXNjYW46CiAJZm9yIChpID0gMDsgaSA8PSB0YmwtPmhhc2hf
bWFzazsgaSsrKSB7CiAJCXN0cnVjdCBuZWlnaGJvdXIgKm4sICoqbnA7CiAKQEAgLTEyNSwzMCAr
MTI1LDQ2IEBACiAJCQkvKiBOZWlnaGJvdXIgcmVjb3JkIG1heSBiZSBkaXNjYXJkZWQgaWY6CiAJ
CQkgICAtIG5vYm9keSByZWZlcnMgdG8gaXQuCiAJCQkgICAtIGl0IGlzIG5vdCBwZXJtYW5lbnQK
LQkJCSAgIC0gKE5FVyBhbmQgcHJvYmFibHkgd3JvbmcpCisJCQkgICAtIE9uIHRoZSBmaXJzdCBw
YXNzIG9mIHRoaXMgc2NhbiwKIAkJCSAgICAgSU5DT01QTEVURSBlbnRyaWVzIGFyZSBrZXB0IGF0
IGxlYXN0IGZvcgogCQkJICAgICBuLT5wYXJtcy0+cmV0cmFuc190aW1lLCBvdGhlcndpc2Ugd2Ug
Y291bGQKIAkJCSAgICAgZmxvb2QgbmV0d29yayB3aXRoIHJlc29sdXRpb24gcmVxdWVzdHMuCi0J
CQkgICAgIEl0IGlzIG5vdCBjbGVhciwgd2hhdCBpcyBiZXR0ZXIgdGFibGUgb3ZlcmZsb3cKLQkJ
CSAgICAgb3IgZmxvb2RpbmcuCiAJCQkgKi8KIAkJCXdyaXRlX2xvY2soJm4tPmxvY2spOwotCQkJ
aWYgKGF0b21pY19yZWFkKCZuLT5yZWZjbnQpID09IDEgJiYKLQkJCSAgICAhKG4tPm51ZF9zdGF0
ZSAmIE5VRF9QRVJNQU5FTlQpICYmCi0JCQkgICAgKG4tPm51ZF9zdGF0ZSAhPSBOVURfSU5DT01Q
TEVURSB8fAotCQkJICAgICB0aW1lX2FmdGVyKGppZmZpZXMsIG4tPnVzZWQgKyBuLT5wYXJtcy0+
cmV0cmFuc190aW1lKSkpIHsKLQkJCQkqbnAJPSBuLT5uZXh0OwotCQkJCW4tPmRlYWQgPSAxOwot
CQkJCXNocnVuawk9IDE7Ci0JCQkJd3JpdGVfdW5sb2NrKCZuLT5sb2NrKTsKLQkJCQluZWlnaF9y
ZWxlYXNlKG4pOwotCQkJCWNvbnRpbnVlOworCQkJaWYgKGF0b21pY19yZWFkKCZuLT5yZWZjbnQp
ICE9IDEpCisJCQkJZ290byBuZXh0X2VudDsKKworCQkJaWYgKG4tPm51ZF9zdGF0ZSAmIE5VRF9Q
RVJNQU5FTlQpCisJCQkJZ290byBuZXh0X2VudDsKKworCQkJaWYgKG4tPm51ZF9zdGF0ZSA9PSBO
VURfSU5DT01QTEVURSAmJgorCQkJICAgIHJlYXBfaW5jb21wbGV0ZSA9PSAwICYmCisJCQkgICAg
dGltZV9hZnRlcihqaWZmaWVzLAorCQkJCSAgICAgICBuLT51c2VkICsgbi0+cGFybXMtPnJldHJh
bnNfdGltZSkpIHsKKwkJCQludW1faW5jb21wbGV0ZSsrOworCQkJCWdvdG8gbmV4dF9lbnQ7CiAJ
CQl9CisKKwkJCSpucAk9IG4tPm5leHQ7CisJCQluLT5kZWFkID0gMTsKKwkJCXNocnVuaysrOwor
CQkJd3JpdGVfdW5sb2NrKCZuLT5sb2NrKTsKKwkJCW5laWdoX3JlbGVhc2Uobik7CisJCQljb250
aW51ZTsKKworCQluZXh0X2VudDoKIAkJCXdyaXRlX3VubG9jaygmbi0+bG9jayk7CiAJCQlucCA9
ICZuLT5uZXh0OwogCQl9CiAJfQogCisJaWYgKHJlYXBfaW5jb21wbGV0ZSA9PSAwICYmCisJICAg
IHNocnVuayA8IGdvYWwgJiYKKwkgICAgKHNocnVuayArIG51bV9pbmNvbXBsZXRlKSA+PSBnb2Fs
KSB7CisJCXJlYXBfaW5jb21wbGV0ZSA9IDE7CisJCWdvdG8gcmVzY2FuOworCX0KKwogCXRibC0+
bGFzdF9mbHVzaCA9IGppZmZpZXM7CiAKIAl3cml0ZV91bmxvY2tfYmgoJnRibC0+bG9jayk7CkBA
IC0yNjEsNyArMjc3LDkgQEAKIAlpZiAodGJsLT5lbnRyaWVzID4gdGJsLT5nY190aHJlc2gzIHx8
CiAJICAgICh0YmwtPmVudHJpZXMgPiB0YmwtPmdjX3RocmVzaDIgJiYKIAkgICAgIHRpbWVfYWZ0
ZXIobm93LCB0YmwtPmxhc3RfZmx1c2ggKyA1ICogSFopKSkgewotCQlpZiAoIW5laWdoX2ZvcmNl
ZF9nYyh0YmwpICYmCisJCWludCBnb2FsID0gdGJsLT5lbnRyaWVzIC0gdGJsLT5nY190aHJlc2gz
OworCisJCWlmICghbmVpZ2hfZm9yY2VkX2djKHRibCwgZ29hbCkgJiYKIAkJICAgIHRibC0+ZW50
cmllcyA+IHRibC0+Z2NfdGhyZXNoMykKIAkJCWdvdG8gb3V0OwogCX0K

--Multipart=_Sat__25_Sep_2004_01_30_36_-0700_fNjW+ilCHUf_yLSs--
