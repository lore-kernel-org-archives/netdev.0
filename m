From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: Re: [PATCH] net: macb: NULL out phydev after removing mdio bus
Date: Fri, 7 Oct 2016 08:20:51 -0700
Message-ID: <CAAtXAHeHyz1-HtLqa5rzLWoyEy6+sokRDzE8frVRGt3xomCvPA@mail.gmail.com>
References: <1475853202-19903-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
        Nathan Sullivan <nathan.sullivan@ni.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Brad Mouring <brad.mouring@ni.com>
To: Xander Huff <xander.huff@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:36527 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757107AbcJGPUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 11:20:53 -0400
Received: by mail-ua0-f182.google.com with SMTP id r64so47525053uar.3
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 08:20:52 -0700 (PDT)
In-Reply-To: <1475853202-19903-1-git-send-email-xander.huff@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 7, 2016 at 8:13 AM, Xander Huff <xander.huff@ni.com> wrote:
> From: Nathan Sullivan <nathan.sullivan@ni.com>
>
> To ensure the dev->phydev pointer is not used after becoming invalid in
> mdiobus_unregister, set it to NULL. This happens when removing the macb
> driver without first taking its interface down, since unregister_netdev
> will end up calling macb_close.
>
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Signed-off-by: Brad Mouring <brad.mouring@ni.com>
Reviewed-by: Moritz Fischer <moritz.fischer@ettus.com>
