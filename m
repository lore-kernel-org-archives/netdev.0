From: Brice Goglin <bgoglin@free.fr>
Subject: Re: [PATCH net-next] myri10ge: add adaptive coalescing
Date: Wed, 07 Oct 2009 07:17:46 +0200
Message-ID: <4ACC247A.9020504@free.fr>
References: <4ACB75DB.4060003@myri.com> <20091006.172537.148962576.davem@davemloft.net> <4ACBEEB2.7010703@hp.com>
Reply-To: Brice.Goglin@ens-lyon.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	netdev@vger.kernel.org, gallatin@myri.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:31913
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750703AbZJGF3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 01:29:09 -0400
In-Reply-To: <4ACBEEB2.7010703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> David Miller wrote:
>> From: Brice Goglin <brice@myri.com>
>> Date: Tue, 06 Oct 2009 18:52:43 +0200
>>
>>
>>> This patch adds support for adaptive interrupt coalescing to the
>>> myri10ge driver. It is based on the host periodically look at
>>> statistics and update the NIC coalescing accordingly.
>>>
>>> The NIC only provides packet throughput and we feel that it is a
>>> better heuristics than the packet rate heuristics currently used
>>> in ethtool. Also, assuming that the packet packet rate heuristics
>>> uses what is actually sent on the wire when using TSO, it would be
>>> much more expensive to implement correctly, as the driver would
>>> need to calculate how many packets were sent.
>>>
>>> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
>>> Signed-off-by: Brice Goglin <brice@myri.com>
>>
>>
>> Drivers tried to do this as far back as 6 years ago (tg3) and we don't
>> recommend doing this with NAPI drivers.
>
> Doesn't e1000(e) still try to do adaptive coalescing?

mlx_en, benet, sfc, ... do as well.

Brice

