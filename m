From: Nix <nix@esperi.org.uk>
Subject: Re: [2.6.17.8] NFS stall / BUG in UDP fragment processing / SKB trimming
Date: Sat, 12 Aug 2006 23:17:11 +0100
Message-ID: <87d5b5vbtk.fsf@hades.wkstn.nix>
References: <87zme9fy94.fsf@hades.wkstn.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 41-052.adsl.zetnet.co.uk ([194.247.41.52]:59406 "EHLO
	mail.esperi.org.uk") by vger.kernel.org with ESMTP id S964956AbWHLWRP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 18:17:15 -0400
To: linux-kernel@vger.kernel.org
In-Reply-To: <87zme9fy94.fsf@hades.wkstn.nix> (nix@esperi.org.uk's message of "12 Aug 2006 22:21:26 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12 Aug 2006, nix@esperi.org.uk mused:
> Then the build froze. I couldn't very well ignore *that*. Perhaps I
> couldn't blame XEmacs after all.

It just happened again. It's reproducibly triggered, at least on this
system, by the ocaml-3.09.02 configure script running over NFS (probably
NFS over UDP is necessary as well).

In theory I could now use this to minimise the problem, but the sheer
number of reboots this is likely to need is dissuading me: I'll put it
off until someone actually wants such a minimal crash case :)

-- 
`We're sysadmins. We deal with the inconceivable so often I can clearly 
 see the need to define levels of inconceivability.' --- Rik Steenwinkel
