From: Andi Kleen <ak@muc.de>
Subject: Re: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Wed, 19 May 2004 13:54:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3isespr76.fsf@averell.firstfloor.org>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com>
	<Pine.LNX.4.58.0405151354220.9894@fcat>
	<Pine.LNX.4.58.0405190256010.30653@fcat>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marc Herbert <marc.herbert@free.fr>
In-Reply-To: <Pine.LNX.4.58.0405190256010.30653@fcat> (Marc Herbert's
 message of "Wed, 19 May 2004 11:30:28 +0200 (CEST)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marc Herbert <marc.herbert@free.fr> writes:
>
> PS: several people seem to think TCP "drops" packets when the qdisc is
> full. My analysis of the code _and_=A0my experiments makes me think the=
y
> are wrong: TCP rather "blocks" when the qdisc is full. See explanation
> here: <http://oss.sgi.com/archives/netdev/2004-05/msg00151.html>
> (Subject: Re: TcpOutSegs way too optimistic (netstat -s))

This behaviour was only added relatively recently (in late 2.3.x timefram=
e)
I believe all the default queue lengths tunings were done before that.
So it would probably make sense to reevaluate/rebenchmark the default=20
queue lengths for various devices with the newer code.

-Andi
