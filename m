From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: only works in 10mbit/half duplex
Date: Tue, 9 May 2006 21:01:10 +0200
Message-ID: <20060509190110.GB3215@electric-eye.fr.zoreil.com>
References: <1147137144.16487.61.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:26516 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750828AbWEITDV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 15:03:21 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1147137144.16487.61.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> :
[...]
> I'm thinking this is a hardware failure, is there any reason to believe
> otherwise?

It's hard to tell without data. It could be any of the usual suspects
or a genuine bug.

Can you send the complete dmesg from boot + lspci -vvx + /proc/interrupts
of the computer ?

What does ethtool report if you do not force it to 10Mbps with the media=1
option and what hardware is it connected to ? Any URL for the motherboard ?

-- 
Ueimor
