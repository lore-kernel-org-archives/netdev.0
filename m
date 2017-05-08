From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: init tcp_options before using it.
Date: Mon, 08 May 2017 07:49:23 -0700
Message-ID: <1494254963.7796.55.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1494237477-19023-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35782 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754315AbdEHOt1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:49:27 -0400
Received: by mail-pg0-f44.google.com with SMTP id o3so36654727pgn.2
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 07:49:27 -0700 (PDT)
In-Reply-To: <1494237477-19023-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-08 at 17:57 +0800, Hangbin Liu wrote:
> I searched 4308fc58dced ("tcp: Document use of undefined variable") in
> archive list, but did not find the thread. So I'm not sure why we only
> add a description about un-initialized value.
> 
> Even we don't use tmp_opt.sack_ok, I think it would be more safe to
> initialize the value before using it. Just as other caller did.

Patch is not needed at all.

Comment and code are pretty clear.

This part of the code uses a generic function ( tcp_parse_options()) to
decode TCP options, but we are only caring about TS one.
