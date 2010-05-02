From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: ep93xx_eth stopps receiving packages
Date: Sun, 2 May 2010 12:43:50 +0200
Message-ID: <20100502104350.GS4586@mail.wantstofly.org>
References: <20100419173813.7750395f4fkkmrk0@limpopo.deheime.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stefan Agner <stefan@agner.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:41537 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663Ab0EBLP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 07:15:56 -0400
Content-Disposition: inline
In-Reply-To: <20100419173813.7750395f4fkkmrk0@limpopo.deheime.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 19, 2010 at 05:38:13PM +0200, Stefan Agner wrote:

> I'm using Linux 2.6.32.9 on a technologic systems TS-7250 SBC board, with
> the ep93xx_eth driver for networking. On three identical, but independent
> systems I noted that the system is unreachable after a while. On a serial
> terminal I noted that only the TX counter counts onward, RX stays where it 
> is,
> no matter if i try to ping from or to the system. Wireshark tells me exactly
> that too: I see helpless ARP requests which gets answered, but no ICMP. The
> system doesnt receive the ARP requests, and just sends another one.

(So does the board or does it not respond to ARP requests for its IP?)


> With a simple program which sends small packages in a fast pace I can
> reproduce the problem after several seconds (additional CPU load seem to
> provoke the problem even more). Remove and replug the network cable doesn't
> solve the problem, but ifup/down does. I don't see any messages in dmesg,
> memory is still available.

Do you see interrupts increasing in /proc/interrupts when this happens?
