From: Daniele Fucini <dfucini@gmail.com>
Subject: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 1 Dec 2015 02:00:05 +0100
Message-ID: <20151201010005.GA23175@Fux-PC>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
Cc: jhs@mojatatu.com, davem@davemloft.net, spender@grsecurity.net,
	pageexec@freemail.hu, re.emese@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34377 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbLABAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 20:00:10 -0500
Received: by wmww144 with SMTP id w144so29192652wmw.1
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 17:00:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hello,

I'm using a Grsecurity patched kernel (version 4.2.6-201511282239) and
I'm getting system freezes due to PaX detecting a size overflow in
function qdisc_tree_decrease_qlen net/sched/sch_api.c:769 whenever I use
Transmission BitTorrent client.

On the Grsecurity forum I was told it's probably an unintended integer
underflow that I should report upstream.

Here's the relevant log:
https://gist.github.com/cf54ccbb12ea65e146d4

And here's the thread on Grsecurity forum:
https://forums.grsecurity.net/viewtopic.php?f=3&t=4327

Let me know if there's any other information you need to help debug
this.

Daniele

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWXPEQAAoJEEYRza8bUKw+G3AH/i9smrynD3Jkv07S9ziovdZZ
MwaoSDaekRvg3GZwXqJbbDMUFPskAc0Y2XSiCgNUJyljuAky6j86D+iAzQpOzxKB
ZN6yoeAI6H57xWA9oluDnQW/K3zTzgutxSN9BNXBD2ZRUAyOuYvDZnrCyStF3EMw
w9YPCYMg4C1wHT7soUoH4JrAf1XoL8YcT/iLi6IPiMfZSt2K14Z4ymtJzP9Y0iYn
EAmnVCKdOfaHpPH+soDUo6MW3yIyroQZBAgZeVix2IGQgVzg+hvmBTrjBubgQclo
rOiOjmbYy83QKojwfWRym+CxNjXbwIfU0CbiR0OAwjioFfRRaLExV+emOCzyNOc=
=QmWl
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--
