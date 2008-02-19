From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Tue, 19 Feb 2008 14:26:08 -0500
Message-ID: <47BB2D50.2060805@cybernetics.com>
References: <47BA0984.2070306@cybernetics.com> <1203381120.13495.78.camel@dell> <20080218.163554.74130592.davem@davemloft.net> <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com> <1203448265.13495.95.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:3056 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754500AbYBST0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 14:26:07 -0500
In-Reply-To: <1203448265.13495.95.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
>> The SysKonnect NIC that does not exhibit this problem has a chip that
>> says "BCM5411KQM" "TT0128 P2Q" and "56975E".
> I think this is the 5700, but please send me the tg3 output that
> identifies the chip and the revision.  Something like this:
>
> eth2: Tigon3 [partno(BCM95705) rev 3003 PHY(5705)] (PCI:66MHz:32-bit) 10/100/1000Base-T Ethernet 00:10:18:04:57:0d
> eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
>   
Here is the dmesg output for the SysKonnect NIC:

eth0: Tigon3 [partno(SK-9D21) rev 7104 PHY(5411)] (PCI:66MHz:64-bit)
10/100/1000Base-T Ethernet 00:00:5a:9d:0c:4a
eth0: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] WireSpeed[0] TSOcap[0]
eth0: dma_rwctrl[76ff000f] dma_mask[64-bit]

Tony

