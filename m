From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 11:47:06 -0500 (EST)
Message-ID: <20170116.114706.2025561306237388836.davem@davemloft.net>
References: <1484538981-24591-1-git-send-email-mayhs11saini@gmail.com>
        <7f1c75ec-3cad-0071-9f41-86773361281e@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mayhs11saini@gmail.com, bkenward@solarflare.com,
        netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751361AbdAPQrN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 11:47:13 -0500
In-Reply-To: <7f1c75ec-3cad-0071-9f41-86773361281e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Mon, 16 Jan 2017 09:35:38 +0000

> On 16/01/17 03:56, Shyam Saini wrote:
>> Use eth_zero_addr to assign zero address to the given address array
>> instead of memset when the second argument in memset is address
>> of zero which makes the code clearer and also add header
>> file linux/etherdevice.h
>>
>> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
>> ---
> Acked-by: Edward Cree <ecree@solarflare.com>

Applied to net-next.
