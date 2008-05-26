From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 20:12:16 +0200
Message-ID: <20080526181216.GA12400@elte.hu>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi> <20080526135940.GB24870@elte.hu> <20080526141252.GA31352@elte.hu> <Pine.LNX.4.64.0805261745010.16829@wrl-59.cs.helsinki.fi> <20080526162328.GA9089@elte.hu> <Pine.LNX.4.64.0805261926260.24924@wrl-59.cs.helsinki.fi> <20080526165407.GB24098@elte.hu> <Pine.LNX.4.64.0805261956090.24924@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:45593 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754574AbYEZSMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 14:12:33 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805261956090.24924@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> > Active Internet connections (w/o servers)
> > Proto Recv-Q Send-Q Local Address               Foreign Address    =
         State       PID/Program name  =20
> > tcp        0 207232 europe:37198                europe:distcc      =
         ESTABLISHED 19578/distcc       =20
> > tcp        0      0 europe:ssh                  dione:36284        =
         ESTABLISHED -                  =20
> > tcp        0      0 europe:ssh                  e2:45910           =
         ESTABLISHED -                  =20
> > tcp    72283      0 europe:distcc               europe:37198       =
         ESTABLISHED -                  =20
>=20
> Just to be sure (please forgive me if you find this nearly an insult=20
> :-)), did you have enough rights to find out the pid (ie., if that=20
> process not owned by you then you need superuser privs for that)?

yes, i ran netstat -p as root.

> > the socket does not seem to be owned. It should have closed down?=20
> > Refcounting issue?
>=20
> It's well possible that e.g., net namespaces have some bug in handlin=
g=20
> of orphaned tcp.

yes, that would match the symptoms i think. I half-assumed that it's a=20
state machine problem so i didnt even check what the reader does - and=20
in this case it appears to not exist at all anymore ;-)

	Ingo
