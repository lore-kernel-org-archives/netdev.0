From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: skb->sb on driver xmit
Date: Thu, 1 Jul 2004 22:59:56 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407012300.04290.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I see (kernel 2.4.26) that, sometimes, driver's xmit function gets packet with 
skb->cb containing something from higher level protocols, and non-NULL 
skb->destructor.

 Is it documented? If no, it is worth to do so. Like "In case driver want to 
do some non-trivial manipulations with skb, that involves skb->cb and 
destructor, one should call skb_orphan()."

Also,
"When passing  skb from driver to stack, driver should clear skb->cb. 
Otherwise, stack will get confused."

Vladimir.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD4DBQFA5G1Cqxdj7mhC6o0RAkGnAKCi9xH1qP8Y6lCg2QcTsm2ywWPEoQCYqGml
6SMQsIlyKTBmejQY9yh6HA==
=G3x9
-----END PGP SIGNATURE-----
