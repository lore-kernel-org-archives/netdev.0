From: Peter Bieringer <pb@bieringer.de>
Subject: ICMPv6 ratelimiting, which /proc-settings related?
Date: Sat, 13 Jul 2002 09:57:46 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <17380000.1026547066@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

extending my IPv6-howto with information about the /proc-FS I found
that there is no setting for ICMPv6 rate limiting.

But in "ipv6/icmp.c" there are some " if (net_ratelimit())" calls.

How can this limit be controlled? Is it the
        "/proc/sys/net/ipv4/icmp_ratelimit"
switch?

I see no reaction turning the value from 1 to 10000 and running a 
              ping6 -i 0.1 ::1


TIA,
 Peter
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9L917e1eqe5WPQi0RAgXrAJ404K8wy03ZUdVFVZpOOlAeQ9OdogCgsfUD
/QaVWS9anK4WPPvYEPNOFx4=
=H2fP
-----END PGP SIGNATURE-----
