From: =?UTF-8?Q?St=C3=A9phane?= Glondu <glondu@debian.org>
Subject: Bug#709616: floods the network with pause packets
Date: Sun, 26 May 2013 11:02:47 +0200
Message-ID: <51A1CFB7.1080808@debian.org>
References: <20130524124059.12781.51344.reportbug@wencory.loria.fr>  <20130524160727.GM4752@decadent.org.uk> <51A07081.5010104@debian.org> <1369533273.3469.301.camel@deadeye.wl.decadent.org.uk>
Reply-To: =?UTF-8?Q?St=C3=A9phane?= Glondu <glondu@debian.org>, 709616@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: 709616@bugs.debian.org, e1000-devel@lists.sourceforge.net,
 netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.709616.B709616.13695589725618@bugs.debian.org>
In-Reply-To: <1369533273.3469.301.camel@deadeye.wl.decadent.org.uk>
List-URL: <http://lists.debian.org/debian-bugs-dist/>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Le 26/05/2013 03:54, Ben Hutchings a =C3=A9crit :
> I forgot, e1000e still doesn't report autoneg state completely through
> ethtool.  How about 'mii-tool -v eth0'?

# mii-tool -v eth0
SIOCGMIIREG on eth0 failed: Input/output error
SIOCGMIIREG on eth0 failed: Input/output error
eth0: negotiated 100baseTx-FD flow-control, link ok
  product info: vendor 00:55:00, model 9 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT=
-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-cont=
rol
  link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
10baseT-HD flow-control


I am not sure about who to put in CC of this mail; I've just put the
Debian bug.


Cheers,

--=20
St=C3=A9phane
