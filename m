From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: improve UDP TX performance
Date: Thu, 16 Feb 2017 14:02:43 -0500 (EST)
Message-ID: <20170216.140243.117360399354357581.davem@davemloft.net>
References: <20170216183855.GA4125@felix.cavium.com>
        <b07e968b-4a8c-7d11-d32f-5d53ca0c9f3f@hpe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix.manlunas@cavium.com, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: rick.jones2@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754315AbdBPTCs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 14:02:48 -0500
In-Reply-To: <b07e968b-4a8c-7d11-d32f-5d53ca0c9f3f@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hpe.com>
Date: Thu, 16 Feb 2017 10:43:41 -0800

> On 02/16/2017 10:38 AM, Felix Manlunas wrote:
>> From: VSR Burru <veerasenareddy.burru@cavium.com>
>>
>> Improve UDP TX performance by:
>> * reducing the ring size from 2K to 512
>> * replacing the numerous streaming DMA allocations for info buffers and
>>   gather lists with one large consistent DMA allocation per ring
> 
> By how much was UDP TX performance improved?

I agree, claiming in the commit log message that UDP performance
improves without giving any before/after numbers at all is really
not acceptable.

Thanks.
