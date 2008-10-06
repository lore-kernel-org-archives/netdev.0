From: "Michael H. Warfield" <mhw@WittsEnd.com>
Subject: Fedora 9, IPSec, and 2.6.26 kernels...
Date: Mon, 06 Oct 2008 13:10:54 -0400
Message-ID: <1223313054.25404.37.camel@canyon.wittsend.com>
Reply-To: mhw@WittsEnd.com, "Community assistance, encouragement,
	and advice for using Fedora." <fedora-list@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1119360500=="
Cc: mhw@WittsEnd.com
To: fedora-list@redhat.com, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <fedora-list-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-list>
List-Post: <mailto:fedora-list@redhat.com>
List-Help: <mailto:fedora-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=subscribe>
Sender: fedora-list-bounces@redhat.com
Errors-To: fedora-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org


--===============1119360500==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-qVouPv7JzbNh0I03eb3C"


--=-qVouPv7JzbNh0I03eb3C
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hey all,

        I just ran into this massive problem this weekend.  Several of
my Fedora 9 systems are linked by IPSec (OpenSWAN) tunnels across three
remote sites.  I recently updated the kernels on them (about a half a
dozen systems) to 2.6.26-45 and each and every system with IPsec
destabilized.  They would run for anywhere from a few minutes to a few
hours and then lock dead up.  No network.  Outside pings on IPv4 and
IPv6 all return "no route to host".  If they had X-Windows running,
no response to keyboard.  Mouse MIGHT work but would also shortly lock
up.  USB locked pretty solid.  No ability to log in.  No user space
activity.  Enabled Magic SysRq key and each machine could be rebooted
via Alt-SysRq S-U-B, so interrupts are functioning and the kernel is
responding to the keyboard on that level even if it's a USB keyboard.
Could not switch from X-Windows to a virtual console and cntrl-alt-del
had no effect.  Set sysctl kernel.panic =3D 5 with no effect so there
doesn't seem to be a kernel panic involved that I can't see on the consoles.

        Backed up to the last 2.6.25 kernel and they are all stable again.
All have now been running, once again, for over 24 hours.  I don't know
the status of any intervening 2.6.26 kernels.  The machines that
destabilized had not been rebooted on a 2.6.26 kernel before.  Other
systems with F9 2.6.26-45 kernels w/o IPSec seem stable.  Restarting
OpenSWAN a few times seems to be a pretty reliable way to lock the
system up with or without X Windows present.

        Anyone else seeing this?  Anyone with an idea what might be
going wrong?

        I have not, as yet, tried as non-Fedora kernel.  Some of my other
systems are running OpenVZ kernels (some with IPsec), currently sitting
at 2.6.24, and are stable.  I'll be trying the OpenVZ 2.6.26 kernel as
soon as it's released later this week.

        BTW...  OpenSWAN 2.6.14, in Fedora 9, is pretty well busted for
X.509 certificates (problems in connection identification for X.509).
Been debugging this with the OpenSWAN dudes for the last week or so and
finally got that resolved when  I ran into this.  OpenSWAN 2.6.18 should
resolve the X.509 certificate issues and some rekeying issues.

        Mike
--=20
Michael H. Warfield (AI4NB) | (770) 985-6132 |  mhw@WittsEnd.com
   /\/\|=3Dmhw=3D|\/\/          | (678) 463-0932 |  http://www.wittsend.com=
/mhw/
   NIC whois: MHW9          | An optimist believes we live in the best of a=
ll
 PGP Key: 0xDF1DD471        | possible worlds.  A pessimist is sure of it!


--=-qVouPv7JzbNh0I03eb3C
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQCVAwUASOpGneHJS0bfHdRxAQI9/gP+JMHo2tGRo9ttR0ZiiAqrI07hB1j1ShW1
JH6EhrUolUrSKAmY4XUK6KG0DylQc0gEJg5dlxxI6bNMuU3/6FWTpp12HD98mOgH
IqraFedSYX5ip1/d0yX7o+WF4+2Xbn/MyR0O9jQlNZa1XHcB6iQOKGZv2HgAaKAN
8X+Eyn3G7GI=
=grKN
-----END PGP SIGNATURE-----

--=-qVouPv7JzbNh0I03eb3C--

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.


--===============1119360500==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-- 
fedora-list mailing list
fedora-list@redhat.com
To unsubscribe: https://www.redhat.com/mailman/listinfo/fedora-list
Guidelines: http://fedoraproject.org/wiki/Communicate/MailingListGuidelines
--===============1119360500==--

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.
