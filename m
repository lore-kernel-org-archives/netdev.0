From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: Fix ip_dev_loopback_xmit()
Date: Thu, 15 Apr 2010 17:15:48 -0700 (PDT)
Message-ID: <20100415.171548.179331927.davem@davemloft.net>
References: <1271358783.16881.2949.camel@edumazet-laptop>
	<20100415.142641.125242830.davem@davemloft.net>
	<w2o412e6f7f1004151703xdcc4da16s4eb6308f2578b531@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, eparis@redhat.com, netdev@vger.kernel.org,
	therbert@google.com
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58011
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab0DPAPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 20:15:44 -0400
In-Reply-To: <w2o412e6f7f1004151703xdcc4da16s4eb6308f2578b531@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 16 Apr 2010 08:03:59 +0800

> On Fri, Apr 16, 2010 at 5:26 AM, David Miller <davem@davemloft.net> wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 15 Apr 2010 21:13:03 +0200
>>
>>> [PATCH] ip: Fix ip_dev_loopback_xmit()
>>
>> Applied to net-2.6, thanks Eric.
> 
> 
> Now, I am doubting the correctness of  the following comment:

The ->hard_start_xmit() method always executes with software
interrupts disabled.
