From: Michal Pokrywka <wolfmoon@o2.pl>
Subject: Bug#631945: [Bugme-new] [Bug 39372] New: Problems with HFSC Scheduler
Date: Thu, 04 Aug 2011 15:55:15 +0200
Message-ID: <344feff5.16ac6e1d.4e3aa4c3.49362@o2.pl>
Reply-To: Michal Pokrywka <wolfmoon@o2.pl>, 631945@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: kaber@trash.net,
	soltys@ziu.info,
	akpm@linux-foundation.org,
	netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	hadi@cyberus.ca,
	lucas.bocchi@gmail.com,
	631945@bugs.debian.org,
	00bormoj@gmail.com,
	fdelawarde@wirelessmundi.com
To: eric.dumazet@gmail.com
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.631945.B631945.13124661394321@bugs.debian.org>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

From:=20Michal=20Soltys=20<soltys@ziu.info>
Date:=20Fri,=2029=20Jul=202011=2014:29:10=20+0200

>>=20On=2011-07-22=2011:58,=20Michal=20Pokrywka=20wrote:
>>=20
>>=20commit=20b262a5da755cc6ed0cb4fba230cd9bf4037e1096=20sch=5Fsfq:=20fix=
=20peek()
>>=20implementation
>>=20
>>=20and
>>=20
>>=20commit=209df49f2bfe862573911a080c75a6d81113c5c81d=20sch=5Fsfq:=20avo=
id=20giving
>>=20spurious=20NET=5FXMIT=5FCN=20signals
>>=20
>>=20Reverting=20these=20patches=20makes=20HFSC=20work=20again.
>>=20
>
>=20This=20one=20(upstream=208efa885406359af300d46910642b50ca82c0fe47)=20=
seems=20to=20be
>=20the=20culprit=20(does=20reverting=20only=20that=20one=20cures=20the=20=
problem=20?)

Yes,=20indeed.=20Commit=20b262a5da755cc6ed0cb4fba230cd9bf4037e1096=20is=20=
irrelevant.

Patch=20"sch=5Fsfq:=20fix=20sfq=5Fenqueue()"=20(provided=20by=20Eric=20Du=
mazet)=20applied=20to=202.6.39.1=20fixes=20the=20problem,=20and=20hfsc+sf=
q=20works=20as=20expected.
