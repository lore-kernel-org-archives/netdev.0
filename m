From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2 proposal
Date: Wed, 06 Aug 2008 12:09:16 +0200
Message-ID: <4899784C.5060405@trash.net>
References: <200808060125.38260.denys@visp.net.lb> <489960B3.4050708@trash.net> <200808061304.45392.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44416 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636AbYHFKJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:09:19 -0400
In-Reply-To: <200808061304.45392.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> On Wednesday 06 August 2008, Patrick McHardy wrote:
>> It breaks batches that add links and then configure them. You need
>> to invalidate the link map on "ip link add/del" and "ip tunnel add/del".
 >
> Probably for tc batch it doesn't matter, so this optimization can be done only 
> for tc (i exclude also monitor functions, they must renew list of 
> interfaces).

I'm not sure I understand you correctly. It matters *only* for
tc batch since otherwise the ll map needs to be generated anyways.


> Is new patch looks better? (i test it, it compiles and doesn't break tc, and 
> makes still things much faster on systems with many interfaces).

No patch attached ..
