From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] drivers: ixgbevf: fix unsigned underflow
Date: Thu, 15 Jul 2010 20:28:38 -0700 (PDT)
Message-ID: <20100715.202838.258102741.davem@davemloft.net>
References: <1279219557-12525-1-git-send-email-segooon@gmail.com>
	<43F901BD926A4E43B106BF17856F0755EA96143E@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segooon@gmail.com, kernel-janitors@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, eric.dumazet@gmail.com,
	joe@perches.com, netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935496Ab0GPD2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 23:28:23 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755EA96143E@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Thu, 15 Jul 2010 11:52:54 -0700

>>-----Original Message-----
>>From: Kulikov Vasiliy [mailto:segooon@gmail.com]
>>Sent: Thursday, July 15, 2010 11:46 AM
>>To: kernel-janitors@vger.kernel.org
>>Cc: David S. Miller; Kirsher, Jeffrey T; Rose, Gregory V; Eric Dumazet;
>>Joe Perches; netdev@vger.kernel.org
>>Subject: [PATCH 5/8] drivers: ixgbevf: fix unsigned underflow
>>
>>'count' is unsigned. It is initialized to zero, then it can be increased
>>multiple times, and finally it is used in such a way:
>>
>>   >>>> count--;
>>   |
>>   |    /* clear timestamp and dma mappings for remaining portion of
>>packet */
>>   |    while (count >= 0) {
>>   |            count--;
>>   |            ...
>>   ^
>>If count is zero here (so, it was never increased), we would have a very
>>long loop :)
>>
>>Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
...
> Acked By: Greg Rose <gregory.v.rose@intel.com>

Applied.
