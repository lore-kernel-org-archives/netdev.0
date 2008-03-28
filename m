From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 21:57:46 +0100
Message-ID: <20080328205746.GA31237@atjola.homenet>
References: <47ED3F1A.1090101@linux.intel.com> <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:35800 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754150AbYC1U5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 16:57:49 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.03.28 13:21:38 -0700, Linus Torvalds wrote:
> On Fri, 28 Mar 2008, Arjan van de Ven wrote:
> >=20
> > Rank 1: input_release_device
> > 	This appears to be a regression in 2.6.25; the first reports show =
up
> > in 2.6.25-rc2		Often a warning at kernel/mutex.c:134
> > (mutex_lock_nested), but some oopses too
>=20
> The oopses (at least some of them) seem to be a use-after-free where =
we=20
> seem to do a list_add() on an already-released list head (or we didn'=
t=20
> remove the previous/next entry from a list before we free'd it, and t=
hen=20
> the next list_add() will follow a bogus pointer).
>=20
> > http://www.kerneloops.org/searchweek.php?search=3Dinput_release_dev=
ice
>=20
> The problem with kerneloops is that it seems to be really hard to fig=
ure=20
> out the *source* of the oops. I can find the oopses (and it's really =
good=20
> with the whole search-and-clump-together-by-version thing), but then =
when=20
> some oops like this is found, it's hard to see where your kerneloops=20
> scripts found the oops from, so the context of the oops is all gone.
>=20
> Is there something obvious that I'm missing? I'd really like to see t=
he=20
> whole posting that the oops came from. Do you save the originals or e=
ven=20
> just message ID's from the ones you pick from emails?

The oops for that one seem to be all coming from fc9 systems, which
(IIRC) include the automatic kerneloops reporting tool, so there
probably is no mail for them. Those that come from a mailing list
usually have a link at the top, for example this one:
http://www.kerneloops.org/raw.php?rawid=3D5735&msgid=3Dhttp://mid.gmane=
=2Eorg/20080327230430.GA28795@codemonkey.org.uk

Bj=F6rn
