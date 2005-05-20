From: Felix Fischer <fischer@ikr.uni-stuttgart.de>
Subject: IPv6 Tunneling (reverse tunnel need)
Date: Fri, 20 May 2005 13:19:59 +0200
Message-ID: <200505201319.59707.fischer@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm currently working on a research project and ran into a=20
question regarding tunneling/decapsulation in IPv6.

<------> [ A ] =3D=3D=3D=3D=3D tunnel from A to B =3D=3D=3D=3D=3D> [ B ] =
<-------> =A0

Packets tunneled from A to B are only decapsulated at node B if
B has setup a tunnel-device in direction from B to A (reverse tunnel).

Is the need for the tunnel-device on node B an implementation
issue to handle tunneling, or does it come from something=20
else (i.e. standard requirement) ?

Further, I am wondering why the possibility to use the ANY_ADDRESS
as tunnel-end-point isn't present in IPv6 ?
The IPv4 implementation allows the usage of "0.0.0.0" as remote_address f=
or
tunnel-end-points.


Any help would be greatly appreciated.

Regards,
Felix Fischer
--=20
-------------------------------------------------------------------
Institute of Communication Networks and Computer Engineering (IKR)
University of Stuttgart, Germany
-------------------------------------------------------------------
