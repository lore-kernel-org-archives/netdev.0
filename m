From: Frank Sorenson <frank@tuxrocks.com>
Subject: Kconfig Dependencies for CONFIG_NET_CLS_RSVP6
Date: Fri, 14 Oct 2005 00:37:59 -0600
Message-ID: <434F5247.2040007@tuxrocks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750787AbVJNGiG@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I noticed that I can still select "Special RSVP classifier for IPv6"
even if "The IPv6 protocol" isn't selected.  Should CONFIG_NET_CLS_RSVP6
depend on or select IPV6?

Currently:
Depends on: NET && NET_CLS && NET_QOS


Thanks,
Frank
- --
Frank Sorenson - KD7TZK
Systems Manager, Computer Science Department
Brigham Young University
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFDT1JHaI0dwg4A47wRAhgRAJ0WKH6/S1DjKKRZDSwiLOpIMYJ8cgCgyIld
xXUJRsvCO1TJsCfpSCMj7/A=
=gqzH
-----END PGP SIGNATURE-----
