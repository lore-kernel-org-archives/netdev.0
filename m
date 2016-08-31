From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] tg3: Fix for disallow tx coalescing time to be 0
Date: Wed, 31 Aug 2016 11:25:56 +0200
Message-ID: <351cc329-11da-60e2-bc77-c1e90e91eb49@redhat.com>
References: <1472567935-13177-1-git-send-email-ivecera@redhat.com>
 <50f40ed7-cfed-9e17-8236-ee7242bd7ba1@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: satish.baddipadige@broadcom.com, siva.kallam@broadcom.com,
        michael.chan@broadcom.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50488 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933371AbcHaJ0A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 05:26:00 -0400
In-Reply-To: <50f40ed7-cfed-9e17-8236-ee7242bd7ba1@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 30.8.2016 v 19:52 Sergei Shtylyov napsal(a):
> Hello.
>
> On 08/30/2016 05:38 PM, Ivan Vecera wrote:
>
>> The recent commit 087d7a8c disallows to set Rx coalescing time to be 0
>
>    You should specify both 12-digit SHA1 and the commit summary enclosed in ("").
>
>> as this stops generating interrupts for the incoming packets. I found
>> the zero Tx coalescing time stops generating interrupts similarly for
>> outgoing packets and fires Tx watchdog later. To avoid this, don't allow
>> to set Tx coalescing time to 0.
>>
>> Cc: satish.baddipadige@broadcom.com
>> Cc: siva.kallam@broadcom.com
>> Cc: michael.chan@broadcom.com
>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> [...]
>
> MBR, Sergei
>
No problem, Sergei, will post v2.
