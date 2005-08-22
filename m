From: Dennis <dennismail@gmx.net>
Subject: No Gigabit with r8169 module
Date: Mon, 22 Aug 2005 09:21:17 +0200
Message-ID: <200508220921.17956.dennismail@gmx.net>
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

Hi!

I am trying to build up a gigabit network with the following equipment (a=
ll=20
from Netgear):

- Laptop: GA511 PCMCIA Gigabit Adapter
- PC: GA311 PCI Gigabit Card
- GS605 5-port Gigabit Switch

Both PCMCIA and PCI Cards are running with the r8169 driver. The PC as th=
e=20
laptop are installed with Suse 9.3.
The Switch has dual color support on the connection LEDs and both ports (=
the=20
one connected to the PC and the one connected to the Laptop) are showing =
that=20
they are connected to gigabit ethernet cards.=20

What I tried to do is to copy a folder from the laptop to the PC, which s=
ize=20
is about 6.1 GB. I am using KDE 3.4 and the konqueror with fish-protocol.=
 The=20
copy dialogue says that this wold take about 2.5 hours with a average of =
850=20
kbit/s. This is quite too slow for gigabit.=20

Just to make sure that I didn=B4t make a hardware connection mistake, i t=
ried=20
the connection with Windows XP and there, a folder which size is about 2.=
1 GB=20
takes about 10 minutes to copy - seems like gigabit is actually working w=
ith=20
all cables I am using. Another point was that suse could be the scapegoat=
, so=20
I used knoppix to test the connection under linux again. I got the same s=
low=20
speed here.=20

The laptop has three network interfaces, but I switched all of except the=
=20
gigabit  card (ifdown <device>), so no mistake there possible from my poi=
nt=20
of view (correct me if I am wrong here).

Now I wonder if this is due to the driver or did I do something wrong? I =
would=20
be happy for any help that gets me further to get my gigabit running. If=20
there are any more details I have to supply, please ask me.

Yours,
Mike
