From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] myri10ge: add adaptive coalescing
Date: Tue, 06 Oct 2009 18:28:18 -0700
Message-ID: <4ACBEEB2.7010703@hp.com>
References: <4ACB75DB.4060003@myri.com> <20091006.172537.148962576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com, netdev@vger.kernel.org, gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:45105 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbZJGB25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 21:28:57 -0400
In-Reply-To: <20091006.172537.148962576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brice Goglin <brice@myri.com>
> Date: Tue, 06 Oct 2009 18:52:43 +0200
> 
> 
>>This patch adds support for adaptive interrupt coalescing to the
>>myri10ge driver. It is based on the host periodically look at
>>statistics and update the NIC coalescing accordingly.
>>
>>The NIC only provides packet throughput and we feel that it is a
>>better heuristics than the packet rate heuristics currently used
>>in ethtool. Also, assuming that the packet packet rate heuristics
>>uses what is actually sent on the wire when using TSO, it would be
>>much more expensive to implement correctly, as the driver would
>>need to calculate how many packets were sent.
>>
>>Signed-off-by: Andrew Gallatin <gallatin@myri.com>
>>Signed-off-by: Brice Goglin <brice@myri.com>
> 
> 
> Drivers tried to do this as far back as 6 years ago (tg3) and we don't
> recommend doing this with NAPI drivers.

Doesn't e1000(e) still try to do adaptive coalescing?

rick jones
