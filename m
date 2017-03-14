From: Petr Vorel <petr.vorel@gmail.com>
Subject: Re: [PATCH net] r8152: fix the list rx_done may be used without
 initialization
Date: Tue, 14 Mar 2017 09:53:35 +0100
Message-ID: <20170314085335.j3tqbph5xfr3bn7w@x230>
References: <20170313215714.n2p6j4nxtpxbheaj@dell5510>
 <1394712342-15778-252-Taiwan-albertk@realtek.com>
Reply-To: Petr Vorel <petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36274 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750868AbdCNIxk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 04:53:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id v190so13656336wme.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 01:53:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1394712342-15778-252-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hayes,

> The list rx_done would be initialized when the linking on occurs.
> Therefore, if a napi is scheduled without any linking on before,
> the following kernel panic would happen.

> 	BUG: unable to handle kernel NULL pointer dereference at 000000000000008
> 	IP: [<ffffffffc085efde>] r8152_poll+0xe1e/0x1210 [r8152]
> 	PGD 0
> 	Oops: 0002 [#1] SMP

thanks for fixing!

Kind regards,
Petr
