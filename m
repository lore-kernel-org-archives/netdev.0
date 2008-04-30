From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII
	configurations
Date: Wed, 30 Apr 2008 16:16:15 +0200
Message-ID: <1209564975.16926.8.camel@gentoo-jocke.transmode.se>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
	 <1209540962.18445.8.camel@gentoo-jocke.transmode.se>
	 <fa686aa40804300607k72ef9985m43b3c4111cad6085@mail.gmail.com>
	 <1209561053.16926.2.camel@gentoo-jocke.transmode.se>
	 <fa686aa40804300626v41828f64oc3d0d88ff5954825@mail.gmail.com>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, linuxppc-dev@ozlabs.org, paulus@samba.org,
	netdev@vger.kernel.org, Wolfgang Denk <wd@denx.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:12810 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760166AbYD3OQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 10:16:18 -0400
In-Reply-To: <fa686aa40804300626v41828f64oc3d0d88ff5954825@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-04-30 at 07:26 -0600, Grant Likely wrote:
> On Wed, Apr 30, 2008 at 7:10 AM, Joakim Tjernlund
> <joakim.tjernlund@transmode.se> wrote:
> >
> >
> >  On Wed, 2008-04-30 at 07:07 -0600, Grant Likely wrote:
> >  > On Wed, Apr 30, 2008 at 1:36 AM, Joakim Tjernlund
> >  > <joakim.tjernlund@transmode.se> wrote:
> >  > >
> >  > >  On Tue, 2008-04-29 at 17:06 -0600, Grant Likely wrote:
> >  > >  > From: Grant Likely <grant.likely@secretlab.ca>
> >  > >  >
> >  > >  > Various improvements for configuring the MPC5200 MII link from the
> >  > >  > device tree:
> >  > >  > * Look for 'current-speed' property for fixed speed MII links
> >  > >
> >  > >  Not that I have looked, but why can't you use the fixed-link property?
> >  >
> >  > fixed-link seems to be a recent invention, whereas current-speed is
> >  > better know having already been in use with serial devices.  It seemed
> >  > to me to be a better choice, but my opinion can probably be swayed
> >  > (arguments welcome).
> >
> >  yes it is fairly new. You get alot more than just speed: Duplex/Pause
> >  You need these too.
> 
> duplex I've got.  pause I don't need.

dunno how you speify Half/Full Duplex, but isn't it possible that
someone else wants to use Pause in the future?
Isn't the point that everyone should use fixed-link when it is there
for this purpose?

 Jocke

  Jocke
