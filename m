From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH RFT net-next 0/4] via-rhine receive buffers rework
Date: Tue, 07 Apr 2015 11:46:22 +0100
Message-ID: <87sicci5c1.fsf@spindle.srvr.nix>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
	<87wq1plyjz.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:50730 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbbDGKqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 06:46:31 -0400
In-Reply-To: <87wq1plyjz.fsf@spindle.srvr.nix> (nix@esperi.org.uk's message of
	"Mon, 06 Apr 2015 22:46:56 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 Apr 2015, nix@esperi.org.uk verbalised:

> On 6 Apr 2015, Francois Romieu outgrape:
>
>> This is an hopefully readable rework of my patch from two days ago.
>> It's different enough that it imho requires someone's Tested-by.
>
> I'll give it a torturing tomorrow.

Tormented by routing a simultaneous iperf and make-over-nfs through it
(with the make using ccache, and the ccache cache directory *also*
accessed via nfs, to hit it really hard :) ).

No crashes in several hours of running: looks good!

-- 
NULL && (void)
