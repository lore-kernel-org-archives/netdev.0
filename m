From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Sun, 19 Aug 2007 17:47:59 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>
References: <8A71B368A89016469F72CD08050AD334018E209C@maui.asicdesigners.com><20070819.160428.76330262.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E20BC@maui.asicdesigners.com>
	<20070819.174017.77241227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: "David Miller" <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, August 19, 2007 5:40 PM
> To: Felix Marti
> Cc: sean.hefty@intel.com; netdev@vger.kernel.org; rdreier@cisco.com;
> general@lists.openfabrics.org; linux-kernel@vger.kernel.org;
> jeff@garzik.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
>=20
> From: "Felix Marti" <felix@chelsio.com>
> Date: Sun, 19 Aug 2007 17:32:39 -0700
>=20
> [ Why do you put that "[Felix Marti]" everywhere you say something?
>   It's annoying and superfluous. The quoting done by your mail client
>   makes clear who is saying what. ]
>=20
> > Hmmm, interesting... I guess it is impossible to even have
> > a discussion on the subject.
>=20
> Nice try, Herbert Xu gave a great explanation.
[Felix Marti] David and Herbert, so you agree that the user<>kernel
space memory copy overhead is a significant overhead and we want to
enable zero-copy in both the receive and transmit path? - Yes, copy
avoidance is mainly an API issue and unfortunately the so widely used
(synchronous) sockets API doesn't make copy avoidance easy, which is one
area where protocol offload can help. Yes, some apps can resort to
sendfile() but there are many apps which seem to have trouble switching
to that API... and what about the receive path?
