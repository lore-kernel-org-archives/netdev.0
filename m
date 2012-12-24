From: Marek Lindner <lindner_marek@yahoo.de>
Subject: Re: [B.A.T.M.A.N.] [PATCH 1/7] batman-adv: Move soft-interface initialization to ndo_init
Date: Tue, 25 Dec 2012 03:37:48 +0800
Message-ID: <201212250337.48595.lindner_marek@yahoo.de>
References: <1353715332-4284-1-git-send-email-sven@narfation.org> <201212242237.07208.lindner_marek@yahoo.de> <CANiGF98L_Ca20Eb+qVuX1126rWoeqQzOASshB7c2LQ-Fi7DiXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pau Koning <paukoning@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Sven Eckelmann <sven@narfation.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm12.bullet.mail.ukl.yahoo.com ([217.146.183.186]:28945 "EHLO
	nm12.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753326Ab2LXTh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 14:37:57 -0500
In-Reply-To: <CANiGF98L_Ca20Eb+qVuX1126rWoeqQzOASshB7c2LQ-Fi7DiXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, December 24, 2012 23:36:03 Pau Koning wrote:
> On Mon, Dec 24, 2012 at 3:37 PM, Marek Lindner <lindner_marek@yahoo.de> 
wrote:
> > On Monday, December 24, 2012 22:22:44 Pau Koning wrote:
> >> On Sat, Nov 24, 2012 at 1:02 AM, Sven Eckelmann <sven@narfation.org> 
wrote:
> >> > The initialization of an net_device object should be done in the
> >> > init/constructor function and not from the outside after the
> >> > register_netdevice was done to avoid race conditions.
> >> 
> >> This patchset seems to be similar. Shouldn't it have been part of
> >> 3.8-rc1 or got rejected? Neither of it happened in the last month
> > 
> > It was discussed and a decision was made. Please read all mails in this
> > thread before making noise.
> 
> What decision? I only see something about Patch 6 and Patch 7: Antonio
> Quartulli doesn't want rtnetlink support in batman-adv. I don't see
> any other statement about the rest of the patchset.

Quoting Antonio:

>>>
Anyway, I discussed about this together with the others and it seems
that a proper solution now is to wait before merging this patchset and fix the
current sysfs/rtnl_lock problem first. What do you think?

Adding a new API without fixing the current one doesn't sound like a good 
move.
<<<

What isn't clear ?

Cheers,
Marek
