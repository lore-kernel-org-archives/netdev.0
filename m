From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: fix WARNING in dma_free_coherent()
Date: Fri, 30 Oct 2015 23:47:18 +0300
Message-ID: <5633D756.1030204@cogentembedded.com>
References: <5844359.Wmo6777QiE@wasted.cogentembedded.com>
 <1503970.kr1SvaSeoy@wasted.cogentembedded.com>
 <5632A78C.4090807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33086 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932598AbbJ3UrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:47:22 -0400
Received: by lfbf136 with SMTP id f136so25153766lfb.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:47:21 -0700 (PDT)
In-Reply-To: <5632A78C.4090807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/30/2015 02:11 AM, Sergei Shtylyov wrote:

>> Iff the first dma_alloc_coherent()  call fails in sh_eth_ring_init(), the
>> following  is printed to the kernel console:
>>
>> WARNING: CPU: 0 PID: 1 at drivers/base/dma-mapping.c:334
>> dma_common_free_remap+0x48/0x6c()
>
>     Oops, I got the function name wrong in the subject. David, can you fix
> this while applying or should I repost?

    I guess I'll repost (forgot to CC Dave anyway)...

MBR, Sergei
