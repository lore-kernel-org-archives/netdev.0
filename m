From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net v2] tg3: Fix for disallow tx coalescing time to be 0
Date: Thu, 1 Sep 2016 07:39:47 -0700
Message-ID: <CACKFLi=cdxQhAjx=yXcKrkguFkooz7G5P-RztYMDpZcSWHiSbw@mail.gmail.com>
References: <1472722139-22806-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Satish Baddipadige <satish.baddipadige@broadcom.com>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33996 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932241AbcIAOjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 10:39:49 -0400
Received: by mail-oi0-f44.google.com with SMTP id l203so119075668oib.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 07:39:49 -0700 (PDT)
In-Reply-To: <1472722139-22806-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 1, 2016 at 2:28 AM, Ivan Vecera <ivecera@redhat.com> wrote:
> The recent commit 087d7a8c9174 "tg3: Fix for diasllow rx coalescing
> time to be 0" disallow to set Rx coalescing time to be 0 as this stops
> generating interrupts for the incoming packets. I found the zero
> Tx coalescing time stops generating interrupts for outgoing packets
> as well and fires Tx watchdog later. To avoid this, don't allow to set
> Tx coalescing time to 0 and also remove subsequent checks that become
> senseless.
>
> Cc: satish.baddipadige@broadcom.com
> Cc: siva.kallam@broadcom.com
> Cc: michael.chan@broadcom.com
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>
