From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Wed, 12 Apr 2017 10:22:34 -0400
Message-ID: <871ssx1z9x.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170411205237.29309-1-vivien.didelot@savoirfairelinux.com> <edc488b1-8ea1-fc69-0700-68ffaf8f6742@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50608 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752209AbdDLOYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:24:04 -0400
In-Reply-To: <edc488b1-8ea1-fc69-0700-68ffaf8f6742@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 04/11/2017 01:52 PM, Vivien Didelot wrote:
>> This patch moves as is the legacy DSA code from dsa.c to legacy.c,
>> except the few shared symbols which remain in dsa.c.
>> 
>> Compile legacy.o only if a new CONFIG_NET_DSA_LEGACY symbol is enabled,
>> which is true by default.
>> 
>> DSA drivers without legacy support don't need the probe function as well
>> as driver registration helpers anymore, so remove their definitions if
>> CONFIG_NET_DSA_LEGACY is disabled.
>> 
>> NET_DSA_MV88E6060 and NET_DSA_BCM_SF2 now depend on the legacy support.
>
> BCM_SF2 is not dependent on legacy support since it got converted to the
> new API in the past few months.

Oops, my bad. Fixing it.

> You may want to generate your patch with git format-patch -M to help
> detect renames/code movements.

I used --find-copies-harder -C for easier review but I can use -M.

Thanks,

        Vivien
