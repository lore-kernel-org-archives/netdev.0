From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V1 00/14] net/mlx4_en: Optimizations to TX flow
Date: Mon, 6 Oct 2014 15:54:00 +0300
Message-ID: <543290E8.3070609@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com> <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog134.obsmtp.com ([207.126.144.211]:33672 "EHLO
	eu1sys200aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752330AbaJFMyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 08:54:08 -0400
In-Reply-To: <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/2014 3:51 PM, Eric Dumazet wrote:
> On Mon, 2014-10-06 at 09:15 +0300, Amir Vadai wrote:
> 
>> Changes from V0:
>> - Patch 14/14 ("Use the new tx_copybreak to set inline threshold"):
>>   - Use same coding convention as currently is in en_ethtool.c
>> - Patch 1/14 ("Code cleanups in tx path") and Patch 9/14 ("Use local var in
>>   tx flow for skb_shinfo(skb)"):
>>   - local var shinfo was used by mistake in Patch 1/14 while declared at 9/14.
>>     Fixed it for the sake of future bisections
> 
> Hmm... patches were already merged. I am afraid you need to provide one
> patch on top of current net-next, if still needed. Too bad for the
> bisection.
> 
> Thanks !
> 
> 

Yeh, I missed it somehow. Sorry for the spam.

Amir
