From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 3/9] IB/ipoib: Add support for acting as VIF
Date: Wed, 11 Jul 2012 14:46:18 +0300
Message-ID: <4FFD678A.3060701@mellanox.com>
References: <4FFD33B8.5010604@mellanox.com>  <20120711.011912.2063611962030549397.davem@davemloft.net>  <4FFD4E8D.7040608@mellanox.com>  <20120711.030639.1906839917411889365.davem@davemloft.net> <1342002453.3265.7447.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <erezsh@mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:53864 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753842Ab2GKLq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 07:46:26 -0400
In-Reply-To: <1342002453.3265.7447.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/2012 1:27 PM, Eric Dumazet wrote:
> On Wed, 2012-07-11 at 03:06 -0700, David Miller wrote:
>> We have them on the RX flow too, they are called ingress qdiscs (as
>> opposed to egress qdiscs on the TX side).
>>
>> There is nothing mysterious about them, they've been there for more
>> than 15 years.
>
> Sample script [...]

Hi Eric, thanks for the crash / detailed answer... would you agree to 
what I wrote, so we can
use the last twenty bytes of skb->cb[] e.g in a similar manner to the 
way struct ipoib_cb works?

Or.
