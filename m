From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH] ipv6: Need to export ipv6_push_frag_opts for tunneling now.
Date: Mon, 1 May 2017 15:31:02 -0400
Message-ID: <CAEfhGixdYn3Pui9Ft=aXsGpqG8JKV9yv2f9kxiHrkCu-0ie9ng@mail.gmail.com>
References: <20170501.151109.1682060890683033268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:34990 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdEATbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:31:05 -0400
Received: by mail-qt0-f180.google.com with SMTP id y33so96111650qta.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 12:31:04 -0700 (PDT)
Received: from mail-qt0-f172.google.com (mail-qt0-f172.google.com. [209.85.216.172])
        by smtp.gmail.com with ESMTPSA id z33sm11696146qta.48.2017.05.01.12.31.03
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 12:31:03 -0700 (PDT)
Received: by mail-qt0-f172.google.com with SMTP id y33so96111354qta.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 12:31:03 -0700 (PDT)
In-Reply-To: <20170501.151109.1682060890683033268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 1, 2017 at 3:11 PM, David Miller <davem@davemloft.net> wrote:
>
> Since that change also made the nfrag function not necessary
> for exports, remove it.
>
> Fixes: 89a23c8b528b ("ip6_tunnel: Fix missing tunnel encapsulation limit option")
> Signed-off-by: David S. Miller <davem@davemloft.net>
Woops, sorry I missed this.  Thanks for the fix!

Acked-by: Craig Gallek <kraig@google.com>
