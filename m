From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cipso: simplify cipso_v4_translate() when
 !CONFIG_NETLABEL
Date: Wed, 20 Nov 2013 15:06:20 -0500 (EST)
Message-ID: <20131120.150620.1185820553046155927.davem@davemloft.net>
References: <4007061.3MtKnenLV1@sifl>
	<20131120.145511.1303114952026497883.davem@davemloft.net>
	<2049996.Ospk96ghpo@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754896Ab3KTUGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:06:22 -0500
In-Reply-To: <2049996.Ospk96ghpo@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Wed, 20 Nov 2013 14:59:33 -0500

> On Wednesday, November 20, 2013 02:55:11 PM David Miller wrote:
>> 1) This is a cleanup, and therefore not suitable for submission right now
>>    because the net-next tree is closed.
> 
> I wasn't expecting it to go into the current merge window, I was just sending 
> it out now so you'd have it for when things started moving again.  Think of it 
> as spreading the pain out a bit.

When the merge window opens, I make an announcement here on the list
politely asking pople to defer net-next patch submissions until after
the merge window closes and I explicitly announce that net-next is
open again.

>> 2) A more suitable commit log message would have been "Don't needlessly
>>    recompute 'opt[opt_iter + 1]' as we already have it stored in tag_len".
>> 
>>    Then anyone who reads this commit message can say "yes, obviously this
>>    is a correct change and matches what the patch is doing"
> 
> Fair enough.  Do you want a resubmit with your wording once the merge window 
> closes?

... and I announce that net-next is open once more, yes.  Thank you.
