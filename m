From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] geneve: fix fill_info when using collect_metadata
Date: Wed, 24 May 2017 12:20:36 -0700
Message-ID: <CAOrHB_CqAAWpHLuc+apQHbhL6SUS9bcKq3wW_TxbtWEWcgZrSA@mail.gmail.com>
References: <20170523223727.15307-1-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:40400 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935256AbdEXTUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:20:40 -0400
Received: from mfilter12-d.gandi.net (mfilter12-d.gandi.net [217.70.178.129])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id A7C8217209B
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 21:20:38 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([217.70.183.196])
        by mfilter12-d.gandi.net (mfilter12-d.gandi.net [10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id TjwL0RkeA1mL for <netdev@vger.kernel.org>;
        Wed, 24 May 2017 21:20:37 +0200 (CEST)
Received: from mail-wr0-f176.google.com (mail-wr0-f176.google.com [209.85.128.176])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 2E6F51720A1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 21:20:37 +0200 (CEST)
Received: by mail-wr0-f176.google.com with SMTP id w50so60648083wrc.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 12:20:37 -0700 (PDT)
In-Reply-To: <20170523223727.15307-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 3:37 PM, Eric Garver <e@erig.me> wrote:
> Since 9b4437a5b870 ("geneve: Unify LWT and netdev handling.") fill_info
> does not return UDP_ZERO_CSUM6_RX when using COLLECT_METADATA. This is
> because it uses ip_tunnel_info_af() with the device level info, which is
> not valid for COLLECT_METADATA.
>
> Fix by checking for the presence of the actual sockets.
>
> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Eric Garver <e@erig.me>
Thanks for the patch.

Acked-by: Pravin B Shelar <pshelar@ovn.org>


I noticed that the MTU and encal_len calculation in geneve_configure()
also needs to be fixed for collect metadata case. Can you send patch
to fix it?
