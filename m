From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/8] [TCP]: Uninline tcp_set_state
Date: Sat, 12 Jan 2008 19:27:48 -0200
Message-ID: <20080112212748.GB17675@ghostprotocols.net>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi> <20080112130355.74c39ae7@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762860AbYALV1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 16:27:55 -0500
Content-Disposition: inline
In-Reply-To: <20080112130355.74c39ae7@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Jan 12, 2008 at 01:03:55PM -0800, Stephen Hemminger escreveu:
> On Sat, 12 Jan 2008 11:40:10 +0200
> "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> > -
> > -#ifdef STATE_TRACE
> > -	SOCK_DEBUG(sk, "TCP sk=3D%p, State %s -> %s\n",sk, statename[olds=
tate],statename[state]);
> > -#endif=09
> > -}
> >
>=20
>=20
> Since the function is called with a constant state, I guess the assum=
ption
> was that gcc would be smart enough to only include the code needed, i=
t looks like
> either code was bigger or the compiler was dumber than expected

Yup, that is one more instance where having proper tools to check if ou=
r
assumptions are right proves fruitful. I'm very happy for Ilpo to be
doing this work and making the case for us to work even harder on havin=
g
such tools to check if our assumptions are right.

- Arnaldo

P.S. subscribe to dwarves@vger.kernel.org and help us produce even more
such compiler watchdogs, right now changes to the dwarves are being mad=
e
such that we can check if the layout we think is optimal really holds t=
o
that promise :-)

Soon I'll be looking at Ulrich's promising new disasm stuff :-)

Archives: http://news.gmane.org/gmane.comp.debugging.dwarves

- Arnaldo
