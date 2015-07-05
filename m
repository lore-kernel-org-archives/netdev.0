From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH net] mlx4: TCP/UDP packets have L4 hash
Date: Mon, 06 Jul 2015 00:44:56 +0300
Message-ID: <5599A558.4090709@dev.mellanox.co.il>
References: <1435836284.11970.16.camel@edumazet-glaptop2.roam.corp.google.com>	 <55999EA3.4010303@dev.mellanox.co.il> <1436132001.26467.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33851 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbGEVon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 17:44:43 -0400
Received: by wifm2 with SMTP id m2so13617633wif.1
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 14:44:42 -0700 (PDT)
In-Reply-To: <1436132001.26467.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/2015 12:33 AM, Eric Dumazet wrote:
> On Mon, 2015-07-06 at 00:16 +0300, Ido Shamay wrote:
>
>> We can have a relaxation of the condition  by looking only at TCP/UDP
>> CQE indication (without check-sum indications)
>> This can cover us also when device rx-checksuming feature is off.
>> Do we want it or a correlation between check-sum and l4_hash is needed?
> I thought about that, but this was adding a more complex test in fast
> path.
>
> Not sure we should care here, as nobody would disable hardware checksum
> if they care about performance.
I agree, thank you Eric
Acked-by: Ido Shamay <idos@mellanox.com>
>
>
