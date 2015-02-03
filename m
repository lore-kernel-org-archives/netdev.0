From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next 3/4] ethtool: add RX_ALLOC_ORDER to tunable
Date: Tue, 3 Feb 2015 15:19:30 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1502031326260.22700@ws.cisco>
References: <1422707290-939-1-git-send-email-_govind@gmx.com> <1422707290-939-4-git-send-email-_govind@gmx.com> <20150202.192159.66698996958688718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com, edumazet@google.com, ben@decadent.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:49964 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415AbbBCJts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 04:49:48 -0500
In-Reply-To: <20150202.192159.66698996958688718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Feb 2015, David Miller wrote:

> From: Govindarajulu Varadarajan <_govind@gmx.com>
> Date: Sat, 31 Jan 2015 17:58:09 +0530
>
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>
> This is terrible.
>
> You haven't explained what this means.
>
> And to tell you the truth, from what I can tell this tunable is
> very specific to how you have implemented RX frags in the enic
> driver in this series and won't necessarily translate to how
> other drivers manage RX buffers.
>

Yes I agree that this is too specific to driver. From my knowledge mlx4 also
uses similar frag allocation from large order page. Other that these two
drivers, this facility may not make sense to other drivers.

On systems with huge memory we can go higher than order-3, and if user sees that
order-3 are failing, he should be able to reduce the order.

Since this is very driver specific, are you fine if I move this to device sysfs?


> You need to actually design this facility properly, understand
> what the needs are of other drivers and how this facility
> can be relevant for more drivers than your own.
>
