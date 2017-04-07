From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: dsa: Receive path simplifications
Date: Fri, 7 Apr 2017 13:55:00 -0700
Message-ID: <80d79e87-6d12-9693-f9b9-060a38e9c730@gmail.com>
References: <20170407204154.9651-1-f.fainelli@gmail.com>
 <20170407205303.GB7966@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34670 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753460AbdDGUzP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:55:15 -0400
Received: by mail-qt0-f196.google.com with SMTP id x35so11275784qtc.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 13:55:10 -0700 (PDT)
In-Reply-To: <20170407205303.GB7966@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/07/2017 01:53 PM, Andrew Lunn wrote:
> On Fri, Apr 07, 2017 at 01:41:51PM -0700, Florian Fainelli wrote:
>> Hi all,
>>
>> This patch series does factor the common code found in all tag implementations
>> into dsa_switch_rcv(). The original motivation was to add GRO support, but this
>> may be a lot of work with unclear benefits at this point.
>>
>> Florian Fainelli (3):
>>   net: dsa: Do not check for NULL dst in tag parsers
>>   net: dsa: Move skb_unshare() to dsa_switch_rcv()
>>   net: dsa: Factor bottom tag receive functions
> 
> Hey, are you looking in my git repo and stealing my patches? I have a
> pretty much identical set :-)

Actually, I did not at all, good thing we are at the same conference and
not talking about that :)

> 
> I was holding off for the microchip and mediatek drivers to land, so
> to not cause conflicts.

Yes, that's a good point, this just became slightly obsolete since the
mediatek tag code got included.
-- 
Florian
