From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb4vf: fix crash due to manipulating queues before
 registration
Date: Mon, 01 Nov 2010 14:02:56 -0700
Message-ID: <4CCF2B00.3060602@chelsio.com>
References: <1288297007-663-1-git-send-email-leedom@chelsio.com>	<20101028.132122.245402585.davem@davemloft.net>	<8A71B368A89016469F72CD08050AD334088DA49E@maui.asicdesigners.com> <20101029.130559.112585228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6352 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754323Ab0KAVBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:01:33 -0400
In-Reply-To: <20101029.130559.112585228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2010 01:05 PM, David Miller wrote:
> From: "Dimitrios Michailidis"<dm@chelsio.com>
> Date: Fri, 29 Oct 2010 00:36:22 -0700
>
>> Further, I believe moving the call after register_netdev is buggy as
>> open can be called after registration and it can clash with the
>> queue stopping.  It seems then that these netif_tx_stop_all_queues
>> calls have to go now.
> This is a good explanation of why no driver should be touching the
> queue state before the first ->open() call.

I'm sending a series of 3 patches fixing cxgb3, cxgb4, cxgb4vf.

Cheers,
Divy
