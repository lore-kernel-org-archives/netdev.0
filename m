From: "Weber Matthias" <weber@faps.uni-erlangen.de>
Subject: AW: filtering packtes before OS takes care about them
Date: Mon, 28 Feb 2005 19:59:46 +0100
Message-ID: <09766A6E64A068419B362367800D50C0B58A18@moritz.faps.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@oss.sgi.com>
Content-Class: urn:content-classes:message
To: "bert hubert" <ahu@ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I need to develop a special gateway. It shall map exernal ips to internal=
 ports and external ports to internal ips (kind of NAT but connections ha=
ve to be established from external to internal network and vice versa!), =
so the sender,receveiver addresses and ports have to be changed off each =
package received. Afterwards these packets shall be resent via one (out o=
f more) interfaces. Therefore kernel's IP stuff disturbs me, but because =
i want to use TCP/IP at the gateway itself too (the computer runs applica=
tions using IP), i still need it.
Thus the most easiest way should be to be the first one dealing those pac=
kets when they arrive. AFAIK before netfilter gets the packets the kernel=
's router already got them...

Hope i made may needs clear?=20

Thanks for help,
Matthias

-----Urspr=FCngliche Nachricht-----
Von: bert hubert [mailto:ahu@ds9a.nl]=20
Gesendet: Montag, 28. Februar 2005 18:38
An: Weber Matthias
Cc: netdev@oss.sgi.com
Betreff: Re: filtering packtes before OS takes care about them

On Mon, Feb 28, 2005 at 05:16:57PM +0100, Weber Matthias wrote:

> i need a possibility to catch IP4 packets (from ethernet devices)=20
> before OS' netmodules (IP, UDP, TCP, ICMP, ARP, ROUTE, NETFILTER ...)=20
> takes care about them and

Why? It helps if you tell us what you really want, or is this a research =
project?=20

The earliest place I know of is with tc filter, but that is a netfilter h=
ook. So part of netfilter will "see" your code.

What you appear to be asking for is a packet filtering network adaptor?
These exist.

> * to modify packet headers and move packets to interface related=20
> output
> * buffers

Sure you want an operating system?=20

Good luck!

--=20
http://www.PowerDNS.com      Open source, database driven DNS Software=20
http://netherlabs.nl              Open and Closed source services
