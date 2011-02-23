From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Subject: Bug#614622: linux-image-2.6.37-1-686: atl2 NIC claims NO CARRIER after suspend/resume; rmmod+insmod fixes the problem
Date: Tue, 22 Feb 2011 20:34:52 -0500
Message-ID: <4D64643C.1020001@fifthhorseman.net>
References: <20110222180821.5217.2375.reportbug@localhost.localdomain> <1298423651.2211.496.camel@localhost> <0FBC7C9C2640634A8B837C2EFFCFF32F01837E4A48@SHEXMB-01.global.atheros.com>
Reply-To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>, 614622@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig339CE3D7BD00A13946AE0F80"
Cc: Ben Hutchings <ben@decadent.org.uk>, Jay Cliburn <jcliburn@gmail.com>,
 Chris Snook <chris.snook@gmail.com>,
 Jie Yang <Jie.Yang@Atheros.com>,
 "614622@bugs.debian.org" <614622@bugs.debian.org>,
 netdev <netdev@vger.kernel.org>
To: Xiong Huang <Xiong.Huang@Atheros.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.614622.B614622.12984249218363@bugs.debian.org>
In-Reply-To: <0FBC7C9C2640634A8B837C2EFFCFF32F01837E4A48@SHEXMB-01.global.atheros.com>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig339CE3D7BD00A13946AE0F80
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Xiong,

On 02/22/2011 08:22 PM, Xiong Huang wrote:
> after the onboard NIC claims NO Carrier after resuming from suspend-to-=
RAM, how about it if unplug then re-plug the cable ?

i've tried that, and it is not sufficient to remove the NO CARRIER flag
from the output of "ip link".  I've also tried power-cycling the 10/100
miniswitch on the other end of the ethernet cable, but no luck there eith=
er.

So far, the only thing i've found that clears the NO CARRIER state is to
remove and re-insert atl2.ko.

I remain open to other suggestions.  And thanks for the speedy followup!

	--dkg


--------------enig339CE3D7BD00A13946AE0F80
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQJ8BAEBCgBmBQJNZGQ8XxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznpjh0P/1ykSRPTtITsvANxzy8OlJbY
mIR/GrMBi4v17T4NOe/4W5WSLHzgRdwF5egzmrlW3xLTe1oULMPbZ7lV1LruvDDP
aloH2hve+mwb5GZ6kdKeHrSPu2qCYrAN01tuAJRxU29/cWQIcyOeLqXseVEb3qK6
jbmiknGHOBIFXcHH9ZhUnSPq/Ybn8tpCi1FawG9tc/v3YOOPIaQ1AsBz1xi4UWm+
qVsPtSkxF6MTtlaB/4bQClYdq8KsxqgQDucdYUkY2BDR/3hAXXnJoo9GN7ptOhQZ
3u7yEAWPB0cZixjUtYI/ZsJJ1sQ2Z0yN4pN+VPn3oafzUwdu4995Cw2Ca/crfCMv
AKiggo+n7Y9YK61b5GpV6hf7L17nqvHy+oZCkfIGmgt3ichCHsBp0aJe8L9epRDb
U73wc/sdhsYZTY4wjdg7aK8RvRqdEt6jmNGV2yWuK051dELZQQW9xEW8kAwazbuc
Mef3KammCxg/ykkT9nwpPa60HBVoe6vrjdJ4fUigS2paHTdXKY8bpzt/58KIpR+n
GnXIkpk/fvDtgZ/CMHxFiNAKJHkiLSQg/zgKXdiIUrhVTZMhIeGGtKG5NDOvKsvV
xS0LQg7pdGHZZLvcT//84OcJqfhiugFPHRlnPNU+8br69SDdX1uYv8XBYv6GKYOD
Q0HqXHrTSoOYK87/DFjJ
=V/AR
-----END PGP SIGNATURE-----

--------------enig339CE3D7BD00A13946AE0F80--
