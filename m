From: Patrick McHardy <kaber@trash.net>
Subject: Re: pmtu discovery on SA
Date: Wed, 18 Jul 2007 15:14:42 +0200
Message-ID: <469E1242.3050105@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38372 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322AbXGRNPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 09:15:10 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
>>>No more crashes with IPComp and smaller PMTUs.
>>>But the "pmtu discovery on SA ESP/..." messages don't disappear.
>>
>>Thats probably a different issue. Please post the output of
>>"ip -x xfrm state" (obfuscate keys if you care ..).
> 
> 
> Linux (MTU 1500) <-> ADSL router (1492) <-> ... <-> Linux (1500)

In a previous mail you mentioned:

> The router on the ADSL line (behind an ADSL Netopia router via Ethernet)
> crashed too with 1500, now it uses 1492.

So its using 1492 now? Otherwise it would be expected since the
initial MTU calculation would be based on 1500.

Please capture a full ICMP packet (with -s0) and send me the
binary dump.
