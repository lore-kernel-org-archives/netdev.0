From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Mon, 20 May 2013 14:11:18 +1000
Message-ID: <20130520141118.0446bf631737f5b1d686c05a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__20_May_2013_14_11_18_+1000_V9farDVWh/j6CUCg"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:60697 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab3ETELV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 00:11:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__20_May_2013_14_11_18_+1000_V9farDVWh/j6CUCg
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
arch/sparc/net/bpf_jit_comp.c between commit 5199dfe531db ("sparc:
bpf_jit_comp: can call module_free() from any context") from the net-next
tree and commit "bpf: add comments explaining the schedule_work()
operation" from the akpm tree.

The former means that the latter is no longer reqired, so I used the
former and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__20_May_2013_14_11_18_+1000_V9farDVWh/j6CUCg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRmaJmAAoJEECxmPOUX5FEW4IQAKTMpusOfIm3fgfub8amf/H0
o7gJoDlHf7DkbgZF+YCOtPhZKGSfW0yTP9CAggqgAj5sPnzg3Lqt/8gPN6K2qVxT
iV0xVjCCQwFoQ512WKQtuThJRlR5vPF/Gj7VBAc6pLBH2NpiQySBETLzAc6zK7Fp
28DxTpnKO3G+ZqqIHkWYtNg2rdZNbhRF9pY4YbYXJiRqVCQ9IBe5ghHyXEYyetvW
At2Ssfo/pY/b/3OeWI8FYgDUxOEzAYsyC5Yo/W2iYfhNMFSdbxD3gonZMiZCQ6iG
Q9fx4jLbvxvRnbCwwj17wvTITqpQ/2hox52OwI4W6HS90Y0ZfNr/oxOHkvO8WO/v
FbEyuV3dEM+1Jkr4JLEN+lgXPUSFzUVEEMqVL3eaVNWWWa9nq6VqD2B1qrLEkhDl
ihrKWWmyg534Ge7HY9qBOJLM0sdmuDJN+QlH9b96ismXN3qqC/X0ABn9ZP2k1Gr3
XrTrW9BJt3o6Jv/dH3kXQ3E+e8n+ruyudHr68mTZtPUKwIvw8YcYks13rRyFYmey
P9K52kewZKhUmb2t435sT1bHMeMQ/JH9/jql6W64COJurHxipTGQRMps5KIVd1er
8a47kvXz5fzXHWSz5fdZDl6zHXgneErDCCEkgK5ZpfzzFA3/t5UXuSeY+qHXgpeV
UvZdEy1ioSwShJikksvR
=GEya
-----END PGP SIGNATURE-----

--Signature=_Mon__20_May_2013_14_11_18_+1000_V9farDVWh/j6CUCg--
