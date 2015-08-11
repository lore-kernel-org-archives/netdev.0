From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2015-08-11
Date: Tue, 11 Aug 2015 23:04:06 +0300
Message-ID: <20150811200406.GA6173@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's an important regression fix for the 4.2-rc series that ensures
user space isn't given invalid LTK values. The bug essentially prevents
the encryption of subsequent LE connections, i.e. makes it impossible to
pair devices over LE.

Let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 2475b22526d70234ecfe4a1ff88aed69badefba9:

  xen-netback: Allocate fraglist early to avoid complex rollback (2015-08-03 22:23:03 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to cb92205bad2e4dd630b884142dd707b72504c200:

  Bluetooth: fix MGMT_EV_NEW_LONG_TERM_KEY event (2015-08-06 16:36:03 +0200)

----------------------------------------------------------------
Jakub Pawlowski (1):
      Bluetooth: fix MGMT_EV_NEW_LONG_TERM_KEY event

 net/bluetooth/mgmt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVylU2AAoJECQj9vv5qNQSZNAP/3iJySx+Jg7An9YGVQlrP+yA
vEfOMN5PDbaSae/KHRBhE1hWfPIyLx6gVfXAgJqGUPg8ApsPE6pMCBCOgB3ySR3w
m6/dAmm64jMsO8h5SocKPY4/GCcrA7nMNN/jro2F6OXHMsokXmAZvJhd5HrNwiwL
UOwRxJ/YR5zVuvQURzY9YYepzVUoVtpKbLTF8qoEyyMgBCxrFYniSOOt/bhhQCvd
ld6uBNoZSt2IM/fnMc1aWZSOe5eBgggXcxHbtRoH7xsykSX/8M4fCBmLjZh66e8T
U70FN63zSz4HF78o5xLuXjwbNetm+xS/P68drdA5DmkSm23DOo9ePuES3zJ0ERHX
MmwsqRw7hp052swi5BKsWOO7Y7QnR0mi96QWVrIiM7UP44AdYsTk0C7aLGoQsezM
+tbO7KoDm5ZgvHMw0fWFZsvLeqAXFoh/yzc9ISK5btSIgJLkUTUgbnJqnZPVKWA4
0xmD02X5/ut1Cbt7u4TxI773qX8TCriTbr4E6MMSUbB/z/uapyonfp/uaByNDccS
vJfuF2JNiCU9E3G+wqRctVACIWpVHCIHL03iw2cRS0jyVEmB5+liZrdXM/G3NLUN
c1GFr91mRTmopcW/+fdl2d1ZsU+YcJqRiJKD40mV88lcEeEOd8lM4KCw7btCY2Sl
5kIGdkYOzdPyf0LO5ArN
=bm7P
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
