From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,RFC] gianfar: fix BUG under load after introduction of
 skb recycling
Date: Mon, 25 May 2009 00:42:58 -0700 (PDT)
Message-ID: <20090525.004258.82412594.davem@davemloft.net>
References: <20090523115143.GB1672@mail.wantstofly.org>
	<2A79CAF4-334F-4763-82E3-2460377F3078@it-loops.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, afleming@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl
To: mike@it-loops.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759988AbZEYHny@vger.kernel.org>
In-Reply-To: <2A79CAF4-334F-4763-82E3-2460377F3078@it-loops.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Guntsche <mike@it-loops.com>
Date: Sun, 24 May 2009 17:32:05 +0200

> 
> On May 23, 2009, at 13:51, Lennert Buytenhek wrote:
> 
>> Since commit 0fd56bb5be6455d0d42241e65aed057244665e5e ("gianfar:
>> Add support for skb recycling"), gianfar puts skbuffs that are in
>> the rx ring back onto the recycle list as-is in case there was a
>> receive error, but this breaks the following invariant: that all
>> skbuffs on the recycle list have skb->data = skb->head + NET_SKB_PAD.
>>
>>
>> Michael, can you re-test with this version of the patch?
>> Andy, can you see if this is OK with you?
> 
> Hi, I have been running tests with this patch for the last 6 hours and
> had no panics so far.
> So it fixes the issues I am seeing as well.

Since it's now tested, I am applying this to net-2.6 to expedite it's
inclusion into 2.6.30

Thanks.
