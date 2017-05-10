From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net 2/3] net/mlx4_en: Avoid adding steering rules with
 invalid ring
Date: Wed, 10 May 2017 19:55:23 +0300
Message-ID: <CAJ3xEMhEXQ5C8vFVJd6B7E9NXAoNLubSyFmOUrpxAHfJkfGbhw@mail.gmail.com>
References: <1494330324-11752-1-git-send-email-tariqt@mellanox.com> <1494330324-11752-3-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Talat Batheesh <talatb@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35598 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752912AbdEJQzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 12:55:24 -0400
Received: by mail-oi0-f52.google.com with SMTP id l18so1718916oig.2
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 09:55:24 -0700 (PDT)
In-Reply-To: <1494330324-11752-3-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 9, 2017 at 2:45 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Talat Batheesh <talatb@mellanox.com>
>
> Inserting steering rules with illegal ring is an invalid operation, block it.

Hi Dave,

I realized today that the patch introduced a regression, Tariq will
see if to revert it as a whole or fix the regression.

Just wanted to drop you a note and to make sure you don't further
carry it to -stable,

xxit happens :(

Or.
