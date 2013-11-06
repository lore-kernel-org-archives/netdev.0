From: Mathias Krause <mathias.krause@secunet.com>
Subject: Re: [PATCH net-next 0/3] IPsec improvements
Date: Wed, 06 Nov 2013 10:02:13 +0100
Message-ID: <527A0595.9080305@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com> <20131105.234831.2190193542602272571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47958 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751916Ab3KFJCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 04:02:16 -0500
In-Reply-To: <20131105.234831.2190193542602272571.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.11.2013 05:48, David Miller wrote:
> From: Mathias Krause <mathias.krause@secunet.com>
> Date: Tue,  5 Nov 2013 14:54:08 +0100
> 
>> This series moves pskb_put() to the core code -- making the code
>> duplication in caif obsolete (patches 1 and 2).
>>
>> Additionally does this series optimize the IPsec receive path in patch 3
>> by allowing skb_cow_data() to leave the buffer fragmented. I noticed the
>> linearization to be a bottleneck when doing some VPN gateway benchmarks.
>> Linearization of the buffer isn't needed in the receive path as the
>> crypto API (and all other users of skb_cow_data) can handle sg.
>>
>> With patch 3 applied I was able to increase the throughput of an IPsec
>> gateway from 7.12 Gbit/s to 7.28 Gbit/s.
> 
> Please deal with the feedback given to you by Ben about referring to
> variables with the '@' prefix consistently in comments, then resend
> this entire patch series.

Will do. Thanks, Dave.

> 
> Thanks.
