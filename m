From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: ethernet: bcmgenet: use phydev from
 struct net_device"
Date: Sat, 24 Sep 2016 20:02:39 -0700
Message-ID: <bf74c58a-a185-e13b-c41d-478ddf51914c@gmail.com>
References: <1474747110-6496-1-git-send-email-f.fainelli@gmail.com>
 <20160924.201054.1736819083455070537.davem@davemloft.net>
 <9fa471d4-a179-519b-005f-5b52f31c5903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, jaedon.shin@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36503 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbcIYDCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 23:02:42 -0400
Received: by mail-oi0-f65.google.com with SMTP id i193so11437483oib.3
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 20:02:42 -0700 (PDT)
In-Reply-To: <9fa471d4-a179-519b-005f-5b52f31c5903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/24/2016 07:51 PM, Florian Fainelli wrote:
> 
> 
> On 09/24/2016 05:10 PM, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Sat, 24 Sep 2016 12:58:30 -0700
>>
>>> There is already a commit:
>>>
>>> Revert "net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings"
>>>
>>> which should make this apply cleanly to "net" now.
>>
>> But look at net-next, it got re-added there.
>>
>> This is going to be a bit of a merge hassle, and this is why I pushed
>> back on the other attempt to revert this thing.
> 
> OK, so how about this:
> 
> - this patch applies to net which should be okay for now
> - to avoid future conflicts when you merge net into net-next, I submit a
> revert of "net: ethernet: bcmgenet: use
> phy_ethtool_{get|set}_link_ksettings" against net-next
> 
> Does that work for you?

Scratch that, seems like I need to submit another version of this revert
for net-next, let me submit that as well.
