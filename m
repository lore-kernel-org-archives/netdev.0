From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Tue, 16 May 2017 13:58:56 +0200
Message-ID: <1494935936.15923.0.camel@sipsolutions.net>
References: <20170515134711.2770374-1-arnd@arndb.de>
         <20170515142520.GA13996@redhat.com>
         <20170515.103951.2305484593464882104.davem@davemloft.net>
         <20170516115511.GA4230@redhat.com> (sfid-20170516_135707_063500_1838FD88)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, helmut.schaa@googlemail.com, kvalo@codeaurora.org,
        daniel@makrotopia.org, dev@kresin.me, pozega.tomislav@gmail.com,
        vasilugin@yandex.ru, roman@advem.lv,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56066 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750839AbdEPL7S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 07:59:18 -0400
In-Reply-To: <20170516115511.GA4230@redhat.com> (sfid-20170516_135707_063500_1838FD88)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-16 at 13:55 +0200, Stanislaw Gruszka wrote:
> 
> In rt2x00 driver we use poor convention in other kind of registers
> accessors like bbp, mac, eeprom. I dislike to changing only rfcsr
> accessors and leaving others in the old way. And changing all
> accessors would be massive and error prone change, which I'm not
> prefer either.

That's a stupid argument, but for the sake of it - the conversion can
easily be done with coccinelle/spatch without being "error prone".

johannes
