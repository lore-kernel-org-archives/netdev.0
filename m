From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH RFT net-next #2 0/6] via-rhine receive buffers rework
Date: Mon, 13 Apr 2015 14:16:11 +0100
Message-ID: <87pp78dv8k.fsf@spindle.srvr.nix>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
	<87vbh6364u.fsf@spindle.srvr.nix>
	<20150408215051.GA25326@electric-eye.fr.zoreil.com>
	<87r3rtjhtn.fsf@spindle.srvr.nix>
	<20150409224141.GA17832@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:42194 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbbDMNQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 09:16:21 -0400
In-Reply-To: <20150409224141.GA17832@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Fri, 10 Apr 2015 00:41:41 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 Apr 2015, Francois Romieu told this:

> Nix <nix@esperi.org.uk> :
> [...]
>> Of course now I've done this it's not crashing! Maybe it's netconsole-
>> related on top of everything else, or I'm just being unlucky... I'll
>> keep trying.
>
> Please no netconsole yet.

Still trying. It hasn't crashed since I turned netconsole off despite a
couple of days of loading, so it's quite possible that this crash is
netconsole-related. (Without the receive buffers rework, the crash is
much faster and happens even without netconsole, so the rework is
clearly necessary and definitely improves things dramatically.)

-- 
NULL && (void)
