From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/9] net: get rid of most __napi_complete()
 usages
Date: Sat, 04 Feb 2017 14:17:29 -0800
Message-ID: <1486246649.21871.150.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170204182038.3752-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34819 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBDWRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 17:17:32 -0500
Received: by mail-io0-f195.google.com with SMTP id m98so5715357iod.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 14:17:31 -0800 (PST)
In-Reply-To: <20170204182038.3752-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-02-04 at 10:20 -0800, Eric Dumazet wrote:
> This patch series removes nine __napi_complete() calls, in an effort
> to harmonize NAPI API and generalize GRO and napi_complete_done()
> 
> Two are left, I was not feeling lucky enough to patch them :/
>  ( aeroflex/greth.c & ibm/emac/mal.c )

I will send a v2, fixing the kbuild detected issue.
