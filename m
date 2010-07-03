From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH] cxgb4: Use kfree_skb for skb pointers
Date: Fri, 02 Jul 2010 23:43:42 -0700 (PDT)
Message-ID: <20100702.234342.71126498.davem@davemloft.net>
References: <20100701094552.GA6188@hera.kernel.org>
	<20100702.222851.59693056.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334081E3D00@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkirjanov@hera.kernel.org, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56254
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753686Ab0GCGna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 02:43:30 -0400
In-Reply-To: <8A71B368A89016469F72CD08050AD334081E3D00@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dimitrios Michailidis" <dm@chelsio.com>
Date: Fri, 2 Jul 2010 22:51:17 -0700

> 
>> From: Denis Kirjanov <dkirjanov@hera.kernel.org>
>> Date: Thu, 1 Jul 2010 09:45:52 +0000
>> 
>> > Use kfree_skb for skb pointers
>> >
>> > Acked-by: Dimitris Michailidis <dm@chelsio.com>
>> > Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
>> 
>> The code is completely different in this part of the driver now, this
>> patch does not apply.
>> 
>> In fact there is no reference to the string "kfree" at all in the
>> l2t.c file of the cxgb4 driver :)
> 
> This patch is for net-next and it should apply there, I see the wrong
> kfree (there's only one kfree).  Denis didn't mention net-next, maybe
> you tried to apply it to net-2.6?

Yes, I did.

That's why people should always indicate what tree a patch is for
in the subject line or similar.
