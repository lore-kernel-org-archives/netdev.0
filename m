From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec freeze
Date: Mon, 16 Jul 2007 16:07:21 +0200
Message-ID: <469B7B99.6040402@trash.net>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51186 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764730AbXGPOI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 10:08:57 -0400
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
>>I'm running IPsec in the same setup as you describe above without
>>problems. I'm probably not seeing ICMP frag requireds on the wire
>>though since I believe the entire path is >= 1492.
>>
>>Could you try to find out whether those are responsible?
>>
> 
> 
> It's definitely the first large packet or corresponding ICMP that
> triggers the crash, slow packets don't harm.
> IPSec on pathes with a PMTU of 1500 works fine.


I recreated the same setup here, but things work fine even with
different MTUs. Please try to narrow it down further or capture
some more information (serial console/netconsole,
CONFIG_DETECT_SOFTLOCKUP, ..).

