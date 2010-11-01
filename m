From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: fix crash due to manipulating queues before
 registration
Date: Mon, 01 Nov 2010 14:06:26 -0700 (PDT)
Message-ID: <20101101.140626.229737015.davem@davemloft.net>
References: <8A71B368A89016469F72CD08050AD334088DA49E@maui.asicdesigners.com>
	<20101029.130559.112585228.davem@davemloft.net>
	<4CCF2B00.3060602@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754461Ab0KAVGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:06:04 -0400
In-Reply-To: <4CCF2B00.3060602@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 01 Nov 2010 14:02:56 -0700

> On 10/29/2010 01:05 PM, David Miller wrote:
>> From: "Dimitrios Michailidis"<dm@chelsio.com>
>> Date: Fri, 29 Oct 2010 00:36:22 -0700
>>
>>> Further, I believe moving the call after register_netdev is buggy as
>>> open can be called after registration and it can clash with the
>>> queue stopping.  It seems then that these netif_tx_stop_all_queues
>>> calls have to go now.
>> This is a good explanation of why no driver should be touching the
>> queue state before the first ->open() call.
> 
> I'm sending a series of 3 patches fixing cxgb3, cxgb4, cxgb4vf.

Thank you.
