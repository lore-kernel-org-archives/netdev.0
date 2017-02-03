From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Fri, 3 Feb 2017 13:13:47 -0800
Message-ID: <CACKFLimXCkC1=9kvQnz-s5rjTOGe1gmb9Ozvt1tEeW+O=y7yAg@mail.gmail.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com> <20170203.154910.2213640966872850071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:32796 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVNt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:13:49 -0500
Received: by mail-ua0-f174.google.com with SMTP id i68so23042834uad.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:13:48 -0800 (PST)
In-Reply-To: <20170203.154910.2213640966872850071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 12:49 PM, David Miller <davem@davemloft.net> wrote:
>
> Please _DO NOT_ guard XDP support with an ifdef the user
> can modify.
>
> Treat it like any other common netdev feature a driver might
> support such as checksum offloading or GRO.
>

David, I want to make sure I understand completely.  Are you saying
don't use Kconfig option for XDP?  Have it always available?
