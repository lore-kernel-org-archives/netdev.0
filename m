From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Wed, 11 Nov 2009 18:32:00 -0800 (PST)
Message-ID: <20091111.183200.06410858.davem@davemloft.net>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	<4AFA73DA.30308@gmail.com>
	<87d43oka86.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759948AbZKLCbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 21:31:33 -0500
In-Reply-To: <87d43oka86.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 11 Nov 2009 22:44:25 +0100

> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>
>> Problem of possible cpus is the number can be very large on some arches,
>> but yet few cpus online....
> 
> Actually that should be rare. Especially not very large compared to online.

The ratio can be as high as 256/1 on Niagara boxes.
