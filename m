From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix configuration of doorbell block
Date: Mon, 09 Sep 2013 17:07:15 -0400 (EDT)
Message-ID: <20130909.170715.1223677951706730376.davem@davemloft.net>
References: <1378727487-6921-1-git-send-email-ariele@broadcom.com>
	<1378736236.26319.29.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab3IIVHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 17:07:19 -0400
In-Reply-To: <1378736236.26319.29.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Sep 2013 07:17:16 -0700

> On Mon, 2013-09-09 at 14:51 +0300, Ariel Elior wrote:
>> As part of VF RSS feature doorbell block was configured not to use dpm, but
>> a small part of configuration was left out, preventing the driver from sending
>> tx messages to the device. This patch adds the missing configuration.
>> 
>> Reported-by: Eric Dumazet <eric.dumazet@gmil.com>
>> Signed-off-by: Ariel Elior <ariele@broadcom.com>
>> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    1 +
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    3 ---
>>  2 files changed, 1 insertions(+), 3 deletions(-)
> 
> Thanks for fixing this.
> 
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
