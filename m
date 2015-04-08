From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH RFT net-next #2 0/6] via-rhine receive buffers rework
Date: Wed, 08 Apr 2015 18:02:41 +0100
Message-ID: <87vbh6364u.fsf@spindle.srvr.nix>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:40893 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397AbbDHRCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:02:53 -0400
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com> (Francois Romieu's
	message of "Wed, 8 Apr 2015 00:40:47 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 Apr 2015, Francois Romieu stated:

> The series applies without error against v3.19 and davem-next as of
> 812034f11628aaaab0e2d7af1d3bc50a49eb396b ("cxgb4: Move ethtool related
> code to a separate file").

I am sorry to report that I just had a watchdog-triggered autoreboot
during testing of this patch series :( with no log messages of any kind.
looks like the underlying bug is still there, or another bug with the
same symptoms (i.e. some way to crash inside the rx handler). I qwish I
could get some debugging output when this happens!

However, to give some good news, CPU usage is much lower than before the
patch: si ~10%, rather than ~80% with spikes of full CPU usage:
ksoftirqd's CPU usage is steady at about 3% rather than 40--60% with
spikes to 100%, and some of that will be USB interrupts from the
continuous USB traffic from my entropy key.

-- 
NULL && (void)
