From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 05/12] net: dsa: b53: Use a macro to define I/O operations
Date: Mon, 18 Sep 2017 18:12:51 -0400
Message-ID: <87wp4v1wrg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35428 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdIRWQd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:16:33 -0400
In-Reply-To: <20170918214128.27896-6-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Instead of repeating the same pattern: acquire mutex, read/write, release
> mutex, define a macro: b53_build_op() which takes the type (read|write), I/O
> size, and value (scalar or pointer). This helps with fixing bugs that could
> exit (e.g: missing barrier, lock etc.).
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
