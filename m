From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH iproute2] libnetlink: check flag NLM_F_DUMP_INTR during
 dumps
Date: Fri, 22 Mar 2013 15:22:13 +0000
Message-ID: <20130322152213.GB11368@casper.infradead.org>
References: <1363963557-3888-1-git-send-email-nicolas.dichtel@6wind.com>
 <1363964393.4431.66.camel@edumazet-glaptop>
 <514C72B7.8070804@6wind.com>
 <1363965296.4431.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59973 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192Ab3CVPWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:22:18 -0400
Content-Disposition: inline
In-Reply-To: <1363965296.4431.69.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/13 at 08:14am, Eric Dumazet wrote:
> On Fri, 2013-03-22 at 16:03 +0100, Nicolas Dichtel wrote:
> > Le 22/03/2013 15:59, Eric Dumazet a =E9crit :
> > > On Fri, 2013-03-22 at 15:45 +0100, Nicolas Dichtel wrote:
> > >> When this flag is set, it means that dump was interrupted and re=
sult may be
> > >> wrong. Ask user to restart.
> > >>
> > >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > >
> > >
> > > Do we have a guarantee this will complete eventually, on some hos=
ts
> > > constantly adding removing entries ?
> > >
> >=20
> > No. You mean it will be better to just print a warning and continue=
 the dump?
>=20
> I would not break the dump, return the indication, so that caller can
> chose to restart the loop one or two times.

Right, I would do it on an informal level at first. In fact libnl
will do an automatic restart of cache refills but I'm considering
to make it configurable for the application.
