From: Andre Tomt <andre@tomt.net>
Subject: Re: IPv6 bugs introduced in 2.4.21
Date: 18 Jun 2003 14:54:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055940864.7481.163.camel@slurv.ws.pasop.tomt.net>
References: <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On man, 2003-06-16 at 21:50, Andre Tomt wrote:
<snip>
> The lower part of a /127 network is somehow, strangely routed to lo -
> observe..

Replying to myself, with a finding.

I found a temporarily workaround for this problem. Adding the address
with a /128 prefixlen, and then adding a static route entry for the
other end - like this:

ip -6 addr add 2001:730:3::1:2b/128 dev aorta
ip -6 route add 2001:730:3::1:2a/128 dev aorta

.."fixes" the issue.

There is also one more impact of this bug, traffic that travels directly
between the two peers gets discarded, BGP and such breaks this way.

Added CC to usagi-users, and I'm now subscribed to netdev (and
usagi-users), no need for CC'ing me directly. :-)

--=20
Mvh,
Andr=E9 Tomt
