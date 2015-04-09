From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFT net-next #2 0/6] via-rhine receive buffers rework
Date: Fri, 10 Apr 2015 00:41:41 +0200
Message-ID: <20150409224141.GA17832@electric-eye.fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
 <87vbh6364u.fsf@spindle.srvr.nix>
 <20150408215051.GA25326@electric-eye.fr.zoreil.com>
 <87r3rtjhtn.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Nix <nix@esperi.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33387 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704AbbDIWlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 18:41:53 -0400
Content-Disposition: inline
In-Reply-To: <87r3rtjhtn.fsf@spindle.srvr.nix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nix <nix@esperi.org.uk> :
[...]
> The verbosity level is now 16, which should be enough to cover, well,
> everything, and indeed I see extra log at initialization time:

16 ? _warn, _err and _info ought ti be good enough but you should also
check the message level with ethtool as well. You don't want debug
messages from the rx poll handler.

[...]
> Of course now I've done this it's not crashing! Maybe it's netconsole-
> related on top of everything else, or I'm just being unlucky... I'll
> keep trying.

Please no netconsole yet.

-- 
Ueimor
