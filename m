From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT] 3c59x: fix freeing nonexistent resource on driver
 unload
Date: Sun, 05 May 2013 02:07:03 +0400
Message-ID: <51858687.9090201@cogentembedded.com>
References: <201305030110.22462.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:56688 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757081Ab3EDWHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 May 2013 18:07:08 -0400
Received: by mail-la0-f41.google.com with SMTP id fn20so2420029lab.14
        for <netdev@vger.kernel.org>; Sat, 04 May 2013 15:07:05 -0700 (PDT)
In-Reply-To: <201305030110.22462.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/03/2013 01:10 AM, Sergei Shtylyov wrote:

> When unloading the driver that drives an EISA board, a message similar to the
> following one is displayed:
>
> Trying to free nonexistent resource <0000000000013000-000000000001301f>
>
> Then an user is unable to reload the driver because the resource it requested in
> the previous load hasn't been freed. This happens most probably due to a typo in
> vortex_eisa_remove() which calls release_region() with 'dev->base_addr'  instead
> of 'edev->base_addr'...
>
> Reported-by: Matthew Whitehead <tedheadster@gmail.com>

    Should I repost this now with [RFT] removed and this line changed to:

Reported-and-tested-by: Matthew Whitehead <tedheadster@gmail.com>


or could you do it when/if applying, David?

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei
