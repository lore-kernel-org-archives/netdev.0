From: Francois-Xavier Kowalski <francois-xavier_kowalski@hp.com>
Subject: feature request: get ipv6 address from interface name (SIOCGIFNAME)
Date: Mon, 29 Apr 2002 11:48:39 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CCD16F7.1070303@hp.com>
Reply-To: francois-xavier_kowalski@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Francois-Xavier 'FiX' KOWALSKI" <francois-xavier_kowalski@hp.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Linux Networking Development ML <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Hello,

I am currently writing some user-space stuff that require to get the
IP address from the Eternet interface name (because the interface name
is the one linked to the physical device).

ipv4 let the a the ability to retrieve a single address using the
itocl(SIOCGIFNAME) command.

So I am wondering if the fact that this feature is left un-implemented
in ipv6 is intentionnal or not.  The currently implemented ipv6 ioctl
commands only allow to set values, but not to retrieve them.

BTW, I have also noted that a single IPv4 address can be retrieved
using the ioctl(SIOCGIFNAME), whereas the ip(7) command gives the
ability to add several IP addresses per interface (not speaking of the
old "eth0:1" notiation, which is said to be deprecated).

Thanks in advance for any help / explanation or pointer.

Regards

=46iX
--=20
=46ran=E7ois-Xavier 'FiX' KOWALSKI


