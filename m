From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and performance degration
Date: Tue, 20 Mar 2012 19:20:00 +0100
Message-ID: <20120320182000.GA15866@electric-eye.fr.zoreil.com>
References: <20120314223343.23dc9df3@vostro> <20120314205319.GA28394@electric-eye.fr.zoreil.com> <20120315080635.1f76512b@vostro> <20120315171148.0050714d@vostro> <20120315191118.GA19809@electric-eye.fr.zoreil.com> <20120316221557.235f5ffd@vostro> <20120317115625.3fc04de4@vostro> <20120317113501.GC20532@electric-eye.fr.zoreil.com> <20120317222004.GA25455@electric-eye.fr.zoreil.com> <20120320173124.3da2b21c@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34945 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753137Ab2CTSWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 14:22:06 -0400
Content-Disposition: inline
In-Reply-To: <20120320173124.3da2b21c@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> The only differences seem to be the PCI ID field at byte offset 4-5,
> Config 0 field at byte offset 0x14, and the checksum at 0x32-0x33.
> 
> If I understand correctly, the Config 0 bit 0 affects Boot ROM size. It
> affects only the PXE boot sequence?

I have never played with it. I can only tell that it has a different value
for my motherboard included 8168b (see previous messages).

[...]
> But other than that, I'm wondering if the failed mdio writing could have
> caused permanent damage in the PHY.

It's hard to tell and it wouldn't explain the corrupted eeprom.

-- 
Ueimor
