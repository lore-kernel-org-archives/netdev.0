From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT] 3c59x: fix freeing nonexistent resource on driver
 unload
Date: Tue, 07 May 2013 00:45:30 +0400
Message-ID: <5188166A.2050200@cogentembedded.com>
References: <201305030110.22462.sergei.shtylyov@cogentembedded.com> <20130506.122236.49412750367407481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:57056 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756785Ab3EFUpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 16:45:31 -0400
Received: by mail-lb0-f171.google.com with SMTP id u10so6862lbi.2
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 13:45:30 -0700 (PDT)
In-Reply-To: <20130506.122236.49412750367407481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2013 08:22 PM, David Miller wrote:

>
>> When unloading the driver that drives an EISA board, a message similar to the
>> following one is displayed:
>>
>> Trying to free nonexistent resource <0000000000013000-000000000001301f>
>>
>> Then an user is unable to reload the driver because the resource it requested in
>> the previous load hasn't been freed. This happens most probably due to a typo in
>> vortex_eisa_remove() which calls release_region() with 'dev->base_addr'  instead
>> of 'edev->base_addr'...
>>
>> Reported-by: Matthew Whitehead <tedheadster@gmail.com>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Applied, thanks.

    Will you queue this patch for stable?

WBR, Sergei
