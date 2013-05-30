From: =?UTF-8?Q?St=C3=A9phane?= Glondu <glondu@debian.org>
Subject: Bug#709616: floods the network with pause packets
Date: Thu, 30 May 2013 11:21:01 +0200
Message-ID: <51A719FD.9020506@debian.org>
References: <20130524124059.12781.51344.reportbug@wencory.loria.fr>   <20130524160727.GM4752@decadent.org.uk> <51A07081.5010104@debian.org>  <1369533273.3469.301.camel@deadeye.wl.decadent.org.uk>  <51A1CFB7.1080808@debian.org> <1369584645.3469.343.camel@deadeye.wl.decadent.org.uk>
Reply-To: =?UTF-8?Q?St=C3=A9phane?= Glondu <glondu@debian.org>, 709616@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: 709616@bugs.debian.org, e1000-devel@lists.sourceforge.net,
 netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.709616.B709616.136990567111262@bugs.debian.org>
In-Reply-To: <1369584645.3469.343.camel@deadeye.wl.decadent.org.uk>
List-URL: <http://lists.debian.org/debian-bugs-dist/>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Le 26/05/2013 18:10, Ben Hutchings a =C3=A9crit :
> OK, so the switch is indeed defective: it says it can handle pause
> frames, but it can't.

The problem happened on (at least) two different switches from different
manufacturers (Transtec and Netgear).

FWIW, the problem just happened on another machine (with same hardware)
this morning. It is running Ubuntu with kernel 3.5.0-31-generic.

> Could you check whether the switch is also sending pause frames back to
> the port that's generating them?

How exactly do I do that? Is disconnecting the faulty computer and
connecting my laptop in its place right?


Cheers,

--=20
St=C3=A9phane


--=20
To UNSUBSCRIBE, email to debian-bugs-dist-REQUEST@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian=
.org
