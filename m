From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2016-08-25
Date: Thu, 25 Aug 2016 22:17:46 +0300
Message-ID: <20160825191746.GA16954@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2fHTh5uZTiUOsy+g"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are a couple of important Bluetooth fixes for the 4.8 kernel:

 - Memory leak fix for HCI requests
 - Fix sk_filter handling with L2CAP
 - Fix sock_recvmsg behavior when MSG_TRUNC is not set

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit d7226c7a4dd19929d6df4ae04698da2fcf6f875a:

  net: diag: Fix refcnt leak in error path destroying socket (2016-08-23 23:11:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 4f34228b67246ae3b3ab1dc33b980c77c0650ef4:

  Bluetooth: Fix hci_sock_recvmsg when MSG_TRUNC is not set (2016-08-25 20:58:47 +0200)

----------------------------------------------------------------
Daniel Borkmann (1):
      Bluetooth: split sk_filter in l2cap_sock_recv_cb

Frederic Dalleau (1):
      Bluetooth: Fix memory leak at end of hci requests

Luiz Augusto von Dentz (2):
      Bluetooth: Fix bt_sock_recvmsg when MSG_TRUNC is not set
      Bluetooth: Fix hci_sock_recvmsg when MSG_TRUNC is not set

 net/bluetooth/af_bluetooth.c |  2 +-
 net/bluetooth/hci_request.c  |  2 ++
 net/bluetooth/hci_sock.c     |  2 +-
 net/bluetooth/l2cap_core.c   |  8 ++++++++
 net/bluetooth/l2cap_sock.c   | 14 ++++++++++++--
 5 files changed, 24 insertions(+), 4 deletions(-)

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJXv0RaAAoJECQj9vv5qNQSTp0QAKj/bdzD7+cDQq1NizY6WzfS
0oT0B5/vcz7qpB29zglpzM3Me6mwQw7ncKjsDPT8FIXkXa3Td8oHKRB8/d/rywLv
n7MGZOxrb72KKtmW88Jn8XF7qm/BAixliLY3Zz2YOixxJRQOqMqWOPTcgky6OVZ6
vIhRSRPk1P7sCS2XmEb9K8gIbTnw8n7/v3ZTYA2PF4LP2u6Lghj6ln+IcZmVQSdx
YmDZlwVCgDXsvR2E3Tueqv3n4SMKGbj8a0lYcfmMVysXzVxvZRnhaXY6FQI2giYq
Idsd6KvCRKppUZgqFfx7IDVwWrhIISZEDm8DqSJ3FreIS9WsUGmKg4cY1K5eiSB6
dfb/u8q1An6o+5fyyAZGXNEwiywcwKk7UDMEnscDVKytWND9F3tocx/BTOTqIg1G
kTBVrLi18oSEy3U3RMUqEoxPPG9pSrXibeD54ArvY+FqMMSFo0v3wUcHVPvie4aP
f1Oam8Zs6AnilCxuCA//tt4JFGGyWhEXpDILf5hZKRxkZ4zVouy2jfKbgislEj+7
cUrCMTPiLgLXMTuxIa6D+VDQMRfDtNmuri0doQZjck+i81Kl7jRA4j2bjGZCUAIq
eOcwohJtEjSflHmGA3W2GhZeHiSUZNIk+n6ZiMAHvSqz3/qdR/c8ETRPCtk2TnmC
w4idLn5UQZgvQ6ALE4Ma
=mOl7
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
