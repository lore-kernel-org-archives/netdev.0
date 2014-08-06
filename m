From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myri10ge: check for pci_map_page errors
Date: Wed, 06 Aug 2014 13:48:51 -0700 (PDT)
Message-ID: <20140806.134851.991301500346816280.davem@davemloft.net>
References: <20140806132516.GA3222@redhat.com>
	<CAOJe8K1EwVpGeiMSwSX98-Vonxb-2N2nbYVyEVJjZPsu-3=R+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, hykim@myri.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589AbaHFUsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 16:48:52 -0400
In-Reply-To: <CAOJe8K1EwVpGeiMSwSX98-Vonxb-2N2nbYVyEVJjZPsu-3=R+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed, 6 Aug 2014 18:47:48 +0400

> On 8/6/14, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
>> On IOMMU systems DMA mapping can fail, we need to check for that
>> possibility.
>>
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>> ---
>>  drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 21
>> ++++++++++++++++++---
>>  1 file changed, 18 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>> b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>> index f3d5d79..17f869a 100644
>> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> 
> You did miss the one in myri10ge_xmit

Indeed, Stanislaw please take care of that case too and resubmit
this patch.

Thanks.
