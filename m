From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec freeze
Date: Tue, 17 Jul 2007 23:45:41 +0200
Message-ID: <469D3885.7070208@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53933 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936945AbXGQVpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 17:45:55 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
>>I fixed it myself. Daniel, can you please test this patch?
> 
> 
> Many thanks Patrick!!!
> I tested it and found it working!


Thanks for testing.

> No more crashes with IPComp and smaller PMTUs.
> But the "pmtu discovery on SA ESP/..." messages don't disappear.


Thats probably a different issue. Please post the output of
"ip -x xfrm state" (obfuscate keys if you care ..).
