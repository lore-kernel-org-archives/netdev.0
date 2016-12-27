From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: driver r8169 suddenly failed
Date: Tue, 27 Dec 2016 01:12:48 +0100
Message-ID: <20161227001248.GA20172@electric-eye.fr.zoreil.com>
References: <428aa40c-e313-99ae-d3ae-97b6a5ef40e4@modulonet.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
        netdev@vger.kernel.org
To: Robert Grasso <robert.grasso@modulonet.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48819 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753446AbcL0ANA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 19:13:00 -0500
Content-Disposition: inline
In-Reply-To: <428aa40c-e313-99ae-d3ae-97b6a5ef40e4@modulonet.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Grasso <robert.grasso@modulonet.fr> :
[dhcp snafu]
> First of all, can you confirm that I am doing right in posting to you
> (addresses found in README.Debian) ?

It isn't completely wrong.

> If I do, can you help ? I am not very proficient with Ethernet, and I am not
> able to figure out what my provider changed : their hotline is
> underqualified, they are just able to tell that "the signal on the line is
> ok".

You're spoiled. It is more than decent for a company whose core business
used to sell cable TV.

> But if you want me to run various tests, try new versions, I would be
> glad to do so : I would appreciate if I could salvage this Shuttle.

Please try a recent stable vanilla kernel and send a complete dmesg
from boot. I need to identify the specific 816x chipset.

Then record some traffic:

# touch gonzo.pcap && tshark -w gonzo.pcap -i eth1

It should only exhibit small outgoing packets but, well, one never knows.

Check the leds activity to be sure that the network interfaces have not
been renumbered.

Use ethtool to check that tso is disabled. If it isn't, disable it.

-- 
Ueimor
