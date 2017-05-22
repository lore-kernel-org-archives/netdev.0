From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 17/20] net: dsa: add notifier for ageing time
Date: Mon, 22 May 2017 16:45:44 -0400
Message-ID: <87pof0boxz.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com> <20170519210055.9366-18-vivien.didelot@savoirfairelinux.com> <3d37b2dd-476a-d339-d730-f14037140177@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41748 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdEVUrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 16:47:49 -0400
In-Reply-To: <3d37b2dd-476a-d339-d730-f14037140177@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 05/19/2017 02:00 PM, Vivien Didelot wrote:
>> This patch keeps the port-wide ageing time handling code in
>> dsa_port_ageing_time, pushes the requested ageing time value in a new
>> switch fabric notification, and moves the switch-wide ageing time
>> handling code in dsa_switch_ageing_time.
>> 
>> This has the effect that now not only the switch that the target port
>> belongs to can be programmed, but all switches composing the switch
>> fabric. For the moment, keep the current behavior and ignore other
>> switches.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>
>> ---
>>  net/dsa/dsa_priv.h |  8 ++++++++
>>  net/dsa/port.c     | 37 ++++++++-----------------------------
>>  net/dsa/switch.c   | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 62 insertions(+), 29 deletions(-)
>> 
>> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
>> index c19241eb094b..becaf8a61b13 100644
>> --- a/net/dsa/dsa_priv.h
>> +++ b/net/dsa/dsa_priv.h
>> @@ -17,10 +17,18 @@
>>  #include <net/dsa.h>
>>  
>>  enum {
>> +	DSA_NOTIFIER_AGEING_TIME,
>>  	DSA_NOTIFIER_BRIDGE_JOIN,
>>  	DSA_NOTIFIER_BRIDGE_LEAVE,
>
> This is so we keep sorting notifier events alphabetically, right?

Correct. Thanks for your reviews and test!

         Vivien
