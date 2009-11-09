From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Mon, 09 Nov 2009 01:13:11 -0800 (PST)
Message-ID: <20091109.011311.203110058.davem@davemloft.net>
References: <4AF7C1FD.8000302@gmail.com>
	<20091108.232647.47855733.davem@davemloft.net>
	<412e6f7f0911090044v33c331edg6096c0f9b9db4143@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48014
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754625AbZKIJMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 04:12:46 -0500
In-Reply-To: <412e6f7f0911090044v33c331edg6096c0f9b9db4143@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 9 Nov 2009 16:44:05 +0800

> On Mon, Nov 9, 2009 at 3:26 PM, David Miller <davem@davemloft.net> wrote:
>> From: Changli Gao <xiaosuo@gmail.com>
>> Date: Mon, 09 Nov 2009 15:17:17 +0800
>>
>>> check the return value of ndo_select_queue()
>>>
>>> Check the return value of ndo_select_queue(). If the value isn't smaller
>>> than the real_num_tx_queues, print a warning message, and reset it to zero.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>
>> Make it a WARN() so that it ends up in kerneloops.org
>>
> Like this?
>                         WARN(1, "%s selects TX queue %d, "
>                              "but real number of TX queues is %d\n",
>                              dev->name, queue_index, dev->real_num_tx_queues);

Yes, something like that.
