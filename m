From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v3 net-next 1/5] dsa: add support for Microchip KSZ tail
 tagging
Date: Sat, 20 May 2017 02:12:04 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A7D1B8@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40A7C018@CHN-SV-EXMX02.mchp-main.com>,<11dd6b8d-855c-0c97-a10b-79b2b7865eeb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>,
        <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:60043 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756695AbdETCMH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 22:12:07 -0400
In-Reply-To: <11dd6b8d-855c-0c97-a10b-79b2b7865eeb@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +     if (padlen) {
>> +             u8 *pad = skb_put(nskb, padlen);
>> +
>> +             memset(pad, 0, padlen);
>> +     }
>
>Can you use skb_put_padto() here instead of open coding this?
>
>> +
>> +     tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
>> +     tag[0] = 0;
>> +     tag[1] = 1 << p->dp->index; /* destnation port */
>
>typo: destination port
>
>With that fixed:
>
>Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
HI Florian,

Thanks for prompt reviews. Will submit another version.

- Woojung
