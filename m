From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: Top 9 kernel oopses/warnings for the week of December 29th,
	2007
Date: Sat, 29 Dec 2007 20:36:11 +0100
Message-ID: <20071229193611.GA5609@atjola.homenet>
References: <477630CF.5070609@linux.intel.com> <alpine.LFD.0.9999.0712291116190.2778@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:40158 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751882AbXL2TgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2007 14:36:16 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.9999.0712291116190.2778@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2007.12.29 11:18:18 -0800, Linus Torvalds wrote:
>=20
>=20
> On Sat, 29 Dec 2007, Arjan van de Ven wrote:
> >
> > It has been a quiet week due to the holidays, only 55 oops traces
> > have been collected.
>=20
> This would be more useful if it was more readable. As it is, you seem=
 to=20
> have some formatting errors in your automation, where the things are=20
> incorrectly grouped:
>=20
> > Rank 1: sysctl_head_finish
> > 	sysctl table check failed
> > 	Reported 7 times
> > 	Only reported for the proprietary madwifi driver
> > 	More info: http://www.kerneloops.org/search.php?search=3Dsysctl_he=
ad_finish
> > 	Rank 2: __ieee80211_rx
> > 	Warning at net/mac80211/rx.c:1672
>=20
> ie notice how that "Rank 2" got reported as if it was part of the "Ra=
nk 1"=20
> issue.=20

Shows up correctly here. Random guess is that your MUA treats tabs like
spaces when it sees format=3Dflowed. The lines between the different ra=
nks
weren't empty but had a single tab. And for whatever reason (I don't se=
e
any trailing spaces), Arjan's mail had a format=3Dflowed header.

AFAIK, only SPACE CRLF is valid for line-continuation with
format=3Dflowed, not TAB CRLF.  So the above formatting would be the
result of a pointless format=3Dflowed header meeting a MUA that was too
eager searching for line continuations.

Bj=F6rn
