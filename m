From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2014-12-19
Date: Fri, 19 Dec 2014 16:34:00 +0200
Message-ID: <20141219143400.GA20385@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bp/iNruPH9dso1Pn"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:52066 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbaLSOeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 09:34:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's one more pull request for 3.19. It contains the socket type
verification fixes from Al Viro as well as an skb double-free fix for
6lowpan from Jukka Rissanen.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 00c845dbfe2e966a2efd3818e40f46e286ca1ae6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-12-18 16:41:13 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 71bb99a02b32b4cc4265118e85f6035ca72923f0:

  Bluetooth: bnep: bnep_add_connection() should verify that it's dealing with l2cap socket (2014-12-19 13:48:27 +0100)

----------------------------------------------------------------
Al Viro (3):
      Bluetooth: hidp_connection_add() unsafe use of l2cap_pi()
      Bluetooth: cmtp: cmtp_add_connection() should verify that it's dealing with l2cap socket
      Bluetooth: bnep: bnep_add_connection() should verify that it's dealing with l2cap socket

Jukka Rissanen (1):
      Bluetooth: 6lowpan: Do not free skb when packet is dropped

 net/bluetooth/6lowpan.c   | 1 -
 net/bluetooth/bnep/core.c | 3 +++
 net/bluetooth/cmtp/core.c | 3 +++
 net/bluetooth/hidp/core.c | 3 ++-
 4 files changed, 8 insertions(+), 2 deletions(-)


--bp/iNruPH9dso1Pn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUlDdYAAoJECQj9vv5qNQS6ZcP/0RXW7qCgrix61bBhbnj7p7H
WoqMOkhAN301sk+9/WgWHcbN7tT2RNJA6quWI7sgH2XTdeiIoR+xAYDUDIwKdq4+
XZf6sPTHWzARlEJSZygiWOPA8N7ScXYS5cmDvT8eBuBVg/ExsPLhfDY8d4QjJkxt
F7VvQdug6slD9UIZO8Kr/NKtlgHgeW8eucZd4kVQYqxJj9rkefL26Rl1MxnaeuwI
To/jdkQVh2Bho51FnuwVD3Pls39q7tpsBP4i3bFCfh0+TqXqz/KW+FLrEIElOpsK
4vOzSDeSuWomap7fYZxP4YpFKO6dG9941ko3pw8rQ8Cevt5njKbgnZZ9Sz8db4sL
b5MVJVPCPVMwTfIjsM6olBak13oY4xC4/yNhCSQMm3trzoa1N+pW/Nbgqj9psXYv
iuwW7toBB0OXK9thxfqntBRuKuRQMWE6zs7OawpYPtplwA7REHA73kGCG3SGAiPf
9g7/zAsiga+ptdI6OoOjAQ8y/NCdTVtUpdPF+Dost7qiIRS7pH63qieSO6DWclv5
UZcA3GrAIoQtdfzEikW5vtywBM9ZtNAAIazH3oU19CprXLInWXw4o6ZSCjh2PPgg
rIIa4JSySEg78PSkPBbUiVD1V04SyuqDMZrCXGWA+IOiqmwG+JBGPtSLFIsQTJF+
dlqFclSolpR1F3DKVBf+
=T2lg
-----END PGP SIGNATURE-----

--bp/iNruPH9dso1Pn--
