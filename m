From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH RFT net-next 0/4] via-rhine receive buffers rework
Date: Tue, 07 Apr 2015 20:41:16 +0100
Message-ID: <87vbh7enfn.fsf@spindle.srvr.nix>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
	<87wq1plyjz.fsf@spindle.srvr.nix> <87sicci5c1.fsf@spindle.srvr.nix>
	<20150407193110.GB24631@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:50764 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbbDGTl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:41:26 -0400
In-Reply-To: <20150407193110.GB24631@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Tue, 7 Apr 2015 21:31:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 Apr 2015, Francois Romieu stated:

> Nix <nix@esperi.org.uk> :
> [...]
>> No crashes in several hours of running: looks good!
>
> Mildly. :o/
>
> You may never notice if you don't resume and the reset work queue doesn't
> run but patch #4 lacks the bits below.

I don't suspend this box, no, it uses only 5W of power and it's my link
to the internet so suspending it would be a bad move :)

> (rx_head_desc should go away)

I'll test this out on top of the other stuff tomorrow...

-- 
NULL && (void)
