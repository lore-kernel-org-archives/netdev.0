From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: udp4: move GSO functions to udp_offload
Date: Mon, 24 Jun 2013 10:51:18 +0200
Message-ID: <51C80886.9000307@redhat.com>
References: <1370688963-32635-1-git-send-email-dborkman@redhat.com> <1372063295.3301.52.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19862 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760Ab3FXIv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 04:51:26 -0400
In-Reply-To: <1372063295.3301.52.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2013 10:41 AM, Eric Dumazet wrote:
> On Sat, 2013-06-08 at 12:56 +0200, Daniel Borkmann wrote:
>> Similarly to TCP offloading and UDPv6 offloading, move all related
>> UDPv4 functions to udp_offload.c to make things more explicit. Also,
>> by this, we can make those functions static.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   include/net/udp.h      |   7 ++--
>>   net/ipv4/Makefile      |   2 +-
>>   net/ipv4/af_inet.c     |   9 +----
>>   net/ipv4/udp.c         |  75 +------------------------------------
>>   net/ipv4/udp_offload.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
>>   5 files changed, 108 insertions(+), 85 deletions(-)
>>   create mode 100644 net/ipv4/udp_offload.c
>
> Daniel, the same could be done for GRE, ie moving GSO stuff into
> net/ipv4/gre_offload.c
>
> Tell me if you do not have the time to do this, I will handle it.

Ok, I can do this today.

Thanks,

Daniel
