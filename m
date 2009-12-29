From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Mon, 28 Dec 2009 20:14:39 -0500
Message-ID: <20091229011439.GB7037@localhost.localdomain>
References: <20091228201005.GC18422@hmsreliant.think-freely.org>
 <9929d2390912281642o964617kbee6e8a2b9f6c75f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56335 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbZL2BOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 20:14:44 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390912281642o964617kbee6e8a2b9f6c75f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 04:42:09PM -0800, Jeff Kirsher wrote:
> On Mon, Dec 28, 2009 at 12:10, Neil Horman <nhorman@tuxdriver.com> wr=
ote:
> > Hey all-
> > =A0 =A0 =A0 =A0A security discussion was recently given:
> > http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> > And a patch that I submitted awhile back was brought up. =A0Apparen=
tly some of
> > their testing revealed that they were able to force a buffer fragme=
nt in e1000
> > in which the trailing fragment was greater than 4 bytes. =A0As a re=
sult the
> > fragment check I introduced failed to detect the fragement and a pa=
rtial invalid
> > frame was passed up into the network stack. =A0I've written this pa=
tch to correct
> > it. =A0I'm in the process of testing it now, but it makes good logi=
cal sense to
> > me. =A0Effectively it maintains a per-adapter state variable which =
detects a
> > non-EOP frame, and discards it and subsequent non-EOP frames leadin=
g up to _and_
> > _including_ the next positive-EOP frame (as it is by definition the=
 last
> > fragment). =A0This should prevent any and all partial frames from e=
ntering the
> > network stack from e1000
> >
> > Regards
> > Neil
> >
> >
> > =A0e1000.h =A0 =A0 =A0| =A0 =A03 ++-
> > =A0e1000_main.c | =A0 14 ++++++++++++--
> > =A02 files changed, 14 insertions(+), 3 deletions(-)
> >
> >
>=20
> Thanks Neil.  I have add the patch to my queue of patches.
>=20
> --=20
> Cheers,
> Jeff
>=20
Thanks jeff, much appreciated
Happy Holidays
Neil

