From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] tg3: Fix for disallow tx coalescing time to be 0
Date: Tue, 30 Aug 2016 20:52:57 +0300
Message-ID: <50f40ed7-cfed-9e17-8236-ee7242bd7ba1@cogentembedded.com>
References: <1472567935-13177-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: satish.baddipadige@broadcom.com, siva.kallam@broadcom.com,
        michael.chan@broadcom.com
To: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34243 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756356AbcH3RxB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:53:01 -0400
Received: by mail-lf0-f41.google.com with SMTP id p41so751573lfi.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:53:00 -0700 (PDT)
In-Reply-To: <1472567935-13177-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/30/2016 05:38 PM, Ivan Vecera wrote:

> The recent commit 087d7a8c disallows to set Rx coalescing time to be 0

    You should specify both 12-digit SHA1 and the commit summary enclosed in ("").

> as this stops generating interrupts for the incoming packets. I found
> the zero Tx coalescing time stops generating interrupts similarly for
> outgoing packets and fires Tx watchdog later. To avoid this, don't allow
> to set Tx coalescing time to 0.
>
> Cc: satish.baddipadige@broadcom.com
> Cc: siva.kallam@broadcom.com
> Cc: michael.chan@broadcom.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
[...]

MBR, Sergei
