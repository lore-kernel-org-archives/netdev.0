From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Wed, 21 Dec 2016 09:37:24 -0800
Message-ID: <1482341844.8944.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shahark@mellanox.com,
        xiyou.wangcong@gmail.com, gerlitz.or@gmail.com, roid@mellanox.com,
        jiri@mellanox.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33473 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbcLURhl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 12:37:41 -0500
Received: by mail-pg0-f65.google.com with SMTP id g1so15225586pgn.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 09:37:41 -0800 (PST)
In-Reply-To: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-21 at 18:04 +0100, Daniel Borkmann wrote:
> Shahar reported a soft lockup in tc_classify(), where we run into an
> endless loop when walking the classifier chain due to tp->next == tp
> which is a state we should never run into. The issue only seems to
> trigger under load in the tc control path.

Nice fix, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
