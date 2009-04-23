From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/8] iucv / af_iucv patches for net-next-2.6.30-rc1
Date: Thu, 23 Apr 2009 06:38:00 -0700 (PDT)
Message-ID: <20090423.063800.159642504.davem@davemloft.net>
References: <1240400356.13951.11.camel@braunu-laptop>
	<20090423.044343.133646582.davem@davemloft.net>
	<1240492023.11770.5.camel@braunu-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ursula.braun@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754258AbZDWNiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 09:38:08 -0400
In-Reply-To: <1240492023.11770.5.camel@braunu-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Thu, 23 Apr 2009 15:07:03 +0200

> On Thu, 2009-04-23 at 04:43 -0700, David Miller wrote:
>> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
>> Date: Wed, 22 Apr 2009 13:39:16 +0200
>> 
>> > the af_iucv-patches sent today apply to net-next-2.6 without pulling
>> > yesterday's patches for net-2.6.
>> > 
>> > If you prefer to pull net-2.6 first (in order to avoid potential future
>> > merge conflicts), I can rebuild and resend today's net-next-2.6 patches
>> > based on yesterday's af_iucv patches for net-2.6.
>> 
>> I applied them all, then pulled net-2.6 into net-next-2.6 to
>> resolve the conflicts.
>> 
>> Please make sure I did the right thing :-)
> 
> Dave,
> 
> net/iucv/af_iucv.c in net-next-2.6 is almost correct. 4 lines should
> still be deleted. These are the remaining changes:

Please provide a signoff even for fixes like this next time.

>  	/* receive/dequeue next skb:
>  	 * the function understands MSG_PEEK and, thus, does not dequeue skb
> */

Newline added by your email client corrupted the patch.
I fixed this up when applying.
