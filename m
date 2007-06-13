From: Patrick McHardy <kaber@trash.net>
Subject: Re: pmtu discovery on sa esp
Date: Wed, 13 Jun 2007 14:50:34 +0200
Message-ID: <466FE81A.80907@trash.net>
References: <BAY103-DAV17DFF0DD3E0AEE8CCCB1F3B2190@phx.gbl> <466E92E4.4020008@trash.net> <BAY103-DAV16399D5C4B8A85492D8738B2180@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63045 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756254AbXFMMxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 08:53:51 -0400
In-Reply-To: <BAY103-DAV16399D5C4B8A85492D8738B2180@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:
> Patrick McHardy wrote:
> 
>>We have some MTU opimiztations in 2.6.22-rc that might be related.
>>Please check with tcpdump what exactly is happening and whether
>>the 2.6.22-rc box is sending too large packets.
> 
> 
> I have done a tcpdump capture on the external
> interface but I don't see anything strange.


Try dumping on loopback as well.

> (I can send to you the capture if you want/need)
> I have noticed that the mtu on the aes tunnels
> now is equal to 1450 byte (with 2.6.21 it was
> 1428). Let me explain:
> 
> linux 2.6.22-rc4 ->>-AES tunnel ->>- linux 2.6.21 mtu=1450
> linux 2.6.21 ->>-AES tunnel ->>- linux 2.6.22-rc4 mtu=1428
> 
> Now as a collateral effects all the windoze boxes
> aren't able to exchange large packets: I must
> upgrade all ipsec gateway to 2.6.22-rc4 (or
> downgrade this box to 2.6.21 again). Hints?


The question is whether 1450 is correct. Could you send me the
output of "ip x s" (obfuscate keys if you want) and "ip x p"?
What is the MTU of the underlying device? Do the encapsulated
packets still fit?

BTW, are you just using pluto or the entire openswan patch?
