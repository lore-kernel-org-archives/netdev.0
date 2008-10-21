From: Aldo Maggi <sentiniate@tiscali.it>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i
 cannot navigate
Date: Tue, 21 Oct 2008 20:18:57 +0200
Message-ID: <20081021201857.08faf0a7@topolino>
References: <20081021090002.21e64151@topolino>
	<Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/SeNk8_vprkvS0gfOqck+rJR"
Cc: Netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	bugme-daemon@bugzilla.kernel.org
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.mail.tiscali.it ([213.205.33.53]:34325 "EHLO
	jack.mail.tiscali.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbYJUSTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 14:19:09 -0400
In-Reply-To: <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/SeNk8_vprkvS0gfOqck+rJR
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Il giorno Tue, 21 Oct 2008 12:36:33 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> ha scritto:

[...]

>=20
> Can you try this another debug patch below (on 2.6.27.2 is fine). It
> moves the mss to the last position but should keep timestamps in
> place by making wscale as first option. It is well possible that you
> won't get it working at all except with all ts,sack and wscale set to
> 0 (the most likely result). Please try with all wscale,sack,ts
> combinations (no need to provide dumps, just working/not working per
> case)... This should tell us for quite high certaintity what is the
> actual option which is causing this (would it not be the
> mss-at-beginning which is the most likely cause), however, your
> finding may well be specific to your network while the other people
> might a bit different results.

i've compiled 2.6.27.2 source after having patched it with your today's
patch.

it works! i.e. i can navigate (w3m kernel.org) and update (apt-get
update)

i send you anyway the usual tcpdump as in previous msgs, should it be
of any help.

do you want me to provide some more commands output?

waiting...

aldo



--MP_/SeNk8_vprkvS0gfOqck+rJR
Content-Type: application/octet-stream;
 name=tcpdump_2-6-27-2-ilpo-2110-patch
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=tcpdump_2-6-27-2-ilpo-2110-patch

MjA6MTQ6MTUuNzcxNzEwIElQIDE5Mi4xNjguMjU0LjEuNDEyNjQgPiAyMDQuMTUyLjE5MS41Ljgw
OiBTIDI2NzExMjY4ODM6MjY3MTEyNjg4MygwKSB3aW4gNTg0MCA8bm9wLHdzY2FsZSA2LHNhY2tP
Syx0aW1lc3RhbXAgMzQxMzggMCxtc3MgMTQ2MD4KCTB4MDAwMDogIDAwYTAgYzU0MyA1ZmViIDAw
MTAgNWFjNSA2ODFjIDA4MDAgNDUwMCAgLi4uQ18uLi5aLmguLi5FLgoJMHgwMDEwOiAgMDAzYyBh
YzM5IDQwMDAgM2YwNiA0NTNhIGMwYTggZmUwMSBjYzk4ICAuPC45QC4/LkU6Li4uLi4uCgkweDAw
MjA6ICBiZjA1IGExMzAgMDA1MCA5ZjM2IDI5NjMgMDAwMCAwMDAwIGEwMDIgIC4uLjAuUC42KWMu
Li4uLi4KCTB4MDAzMDogIDE2ZDAgZjc3MyAwMDAwIDAxMDMgMDMwNiAwNDAyIDA4MGEgMDAwMCAg
Li4ucy4uLi4uLi4uLi4uLgoJMHgwMDQwOiAgODU1YSAwMDAwIDAwMDAgMDIwNCAwNWI0ICAgICAg
ICAgICAgICAgICAuWi4uLi4uLi4uCjIwOjE0OjE1Ljk5MjUyMyBJUCAxOTIuMTY4LjI1NC4xLjQx
MjY0ID4gMjA0LjE1Mi4xOTEuNS44MDogLiBhY2sgNDIzOTk5MTM3MyB3aW4gOTIgPG5vcCxub3As
dGltZXN0YW1wIDM0MTkzIDExMDMyMTEwMzU+CgkweDAwMDA6ICAwMGEwIGM1NDMgNWZlYiAwMDEw
IDVhYzUgNjgxYyAwODAwIDQ1MDAgIC4uLkNfLi4uWi5oLi4uRS4KCTB4MDAxMDogIDAwMzQgYWMz
YSA0MDAwIDNmMDYgNDU0MSBjMGE4IGZlMDEgY2M5OCAgLjQuOkAuPy5FQS4uLi4uLgoJMHgwMDIw
OiAgYmYwNSBhMTMwIDAwNTAgOWYzNiAyOTY0IGZjYjkgMjI0ZCA4MDEwICAuLi4wLlAuNilkLi4i
TS4uCgkweDAwMzA6ICAwMDVjIDMxODggMDAwMCAwMTAxIDA4MGEgMDAwMCA4NTkxIDQxYzEgIC5c
MS4uLi4uLi4uLi4uQS4KCTB4MDA0MDogIGFhMWIgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgLi4KMjA6MTQ6MTUuOTkyNzg3IElQIDE5Mi4xNjguMjU0LjEuNDEyNjQgPiAyMDQu
MTUyLjE5MS41LjgwOiBQIDA6MjQwKDI0MCkgYWNrIDEgd2luIDkyIDxub3Asbm9wLHRpbWVzdGFt
cCAzNDE5MyAxMTAzMjExMDM1PgoJMHgwMDAwOiAgMDBhMCBjNTQzIDVmZWIgMDAxMCA1YWM1IDY4
MWMgMDgwMCA0NTAwICAuLi5DXy4uLlouaC4uLkUuCgkweDAwMTA6ICAwMTI0IGFjM2IgNDAwMCAz
ZjA2IDQ0NTAgYzBhOCBmZTAxIGNjOTggIC4kLjtALj8uRFAuLi4uLi4KCTB4MDAyMDogIGJmMDUg
YTEzMCAwMDUwIDlmMzYgMjk2NCBmY2I5IDIyNGQgODAxOCAgLi4uMC5QLjYpZC4uIk0uLgoJMHgw
MDMwOiAgMDA1YyAzNzZhIDAwMDAgMDEwMSAwODBhIDAwMDAgODU5MSA0MWMxICAuXDdqLi4uLi4u
Li4uLkEuCgkweDAwNDA6ICBhYTFiIDQ3NDUgNTQyMCAyZjIwIDQ4NTQgNTQ1MCAyZjMxIDJlMzAg
IC4uR0VULi8uSFRUUC8xLjAKCTB4MDA1MDogIDBkMGEgNTU3MyA2NTcyIDJkNDEgNjc2NSA2ZTc0
IDNhMjAgNzczMyAgLi5Vc2VyLUFnZW50Oi53Mwo=

--MP_/SeNk8_vprkvS0gfOqck+rJR--
