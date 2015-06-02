From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 net-next] vlan: Add GRO support for non hardware accelerated
 vlan
Date: Tue, 02 Jun 2015 10:24:29 +0900
Message-ID: <556D05CD.3090607@lab.ntt.co.jp>
References: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <20150601.165132.685895742264313831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:49105 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbbFBBYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 21:24:47 -0400
In-Reply-To: <20150601.165132.685895742264313831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/06/02 8:51, David Miller wrote:
> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Date: Mon,  1 Jun 2015 21:55:06 +0900
> 
>> Currently packets with non-hardware-accelerated vlan cannot be handled
>> by GRO. This causes low performance for 802.1ad and stacked vlan, as their
>> vlan tags are currently not stripped by hardware.
>>
>> This patch adds GRO support for non-hardware-accelerated vlan and
>> improves receive performance of them.
>>
>> Test Environment:
>>  vlan device (.1Q) on vlan device (.1ad) on ixgbe (82599)
>>
>> Result:
>  ...
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> 
> So I applied this, but gave the new offloads a priority of 10.

Thank you for handling the priority.

Thanks,
Toshiaki Makita
