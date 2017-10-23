From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: check master device before put
Date: Mon, 23 Oct 2017 14:58:58 -0400
Message-ID: <871sltofm5.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171023180141.3674-1-vivien.didelot@savoirfairelinux.com> <cda226ca-a1c5-107f-d44f-7b6e93459b51@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54048 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751854AbdJWS67 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:59 -0400
In-Reply-To: <cda226ca-a1c5-107f-d44f-7b6e93459b51@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian, David,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 10/23/2017 11:01 AM, Vivien Didelot wrote:
>> In the case of pdata, the dsa_cpu_parse function calls dev_put() before
>> making sure it isn't NULL. Fix this.
>> 
>> Fixes: 71e0bbde0d88 ("net: dsa: Add support for platform data")
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>
> Did not you want to target 'net' for that though?

I wasn't sure if it was a good candidate for it.

If it is, David can you apply this patch on both trees or do you prefer
me to send a copy to -net?


Thanks,

        Vivien
