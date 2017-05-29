From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Add missing static to stub functions
Date: Mon, 29 May 2017 23:06:51 +0200
Message-ID: <CAK8P3a16ifsiF7qh1wP0E_0e5RRE6SAAFy9K9QuyoAurds-DrA@mail.gmail.com>
References: <20170529125612.110244-1-arnd@arndb.de> <20170529153030.GB21315@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35314 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdE2VGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 17:06:52 -0400
In-Reply-To: <20170529153030.GB21315@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 29, 2017 at 5:30 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, May 29, 2017 at 02:56:01PM +0200, Arnd Bergmann wrote:
>> 'static' was not enough, the helpers must be 'static inline'
>>
>> net/dsa/mv88e6xxx/global2.h:123:12: error: 'mv88e6xxx_g2_misc_4_bit_port' defined but not used [-Werror=unused-function]
>> net/dsa/mv88e6xxx/global2.h:117:12: error: 'mv88e6xxx_g2_pvt_write' defined but not used [-Werror=unused-function]
>>
>> Fixes: c21fbe29f858 ("net: dsa: mv88e6xxx: Add missing static to stub functions")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> Hi Arnd
>
> Dave merged my fix yesterday.

Hi Andrew,

The only commit I see from you in the net/master branch is the partial fix
I referenced in the 'fixes' line (c21fbe29f858), from all I can tell, my fix is
still needed on top. Can you check again?

        Arnd
