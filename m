From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net and
 wireless trees
Date: Tue, 4 Oct 2011 17:14:49 +1100
Message-ID: <20111004171449.de5c45332510a453cc3ff879@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__4_Oct_2011_17_14_49_+1100_OOHQJAq5upA9nka+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Oct_2011_17_14_49_+1100_OOHQJAq5upA9nka+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/brcm80211/brcmsmac/mac80211_if.c between commit
37a41b4affa3 ("mac80211: add ieee80211_vif param to tsf functions") from
the net tree, commit 8a3a3c85e44d ("mac80211: pass vif param to conf_tx()
callback") from the wireless tree and several commits from the staging
tree.

I fixed it up (just removed the forward declarions that were changed by
the former commits) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__4_Oct_2011_17_14_49_+1100_OOHQJAq5upA9nka+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOiqRZAAoJEECxmPOUX5FErKoP/AmwS5HyNOfvBp/EEXOv9dye
QCfuTa8O3zOyCbVruJ5RLPQeOJt+EU/oiHoBiTR7YTIDJjRC649laW9zRSwcOd7h
TX2I1pfaLLRChpOoSbqUiTo8UalP6DPRKEpDlmHhcHTfq1/mASwqNE9ynVOcJVqm
IjD4gefpSR9TUp2y1EzRaeHh4w614zHCmjsEXCXxCC9lStfpncVAdk8NVOhDVhSP
uU44vgkE9BtwdqOZR7H4JjNaCXLQlYmsPp5LO+c6P5ElupOa+W1D2UWe0HCL/93T
/BLQF8TVMzCzekVKUhqls+5sWaFLpGYLrs4LByl4QYK4zNxZgM587/Xo/zXkQSni
3YdaBq2veYQIYe0mavEHMCMzKofAYHo7PPiZYy5y3/6boULu9DECoN3xSXH0/y+n
JEqoTKYZ9MWlGXC6GEbfgJBf+4+jlZBMctC4QOOhfIjqEjksrDIo9K6cb9XG+xEr
vbWckn2jXi01x7LSvuE5Mx1xqLKj0pU5q1tKGwJhyGslyH9NpvUESye4aiQwmJdH
TkciZBB5aAjkd5/juy7Sd9elQWg4tTElBA36vQOWtvoC7JPksiW9DcvpHX4RZ+9q
XCtVvWcKAk+s1rjKMKf8aDfqVj7p5oxZXV4P3LsrEJr/UXbO2/wZLIBmb1CwH4hT
+A1eFsop0Xhk7kXuw2Mm
=ThXa
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Oct_2011_17_14_49_+1100_OOHQJAq5upA9nka+--
