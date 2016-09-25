From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: ethernet: bcmgenet: use phydev from
 struct net_device"
Date: Sat, 24 Sep 2016 19:51:49 -0700
Message-ID: <9fa471d4-a179-519b-005f-5b52f31c5903@gmail.com>
References: <1474747110-6496-1-git-send-email-f.fainelli@gmail.com>
 <20160924.201054.1736819083455070537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, jaedon.shin@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34654 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932162AbcIYCvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 22:51:51 -0400
Received: by mail-oi0-f67.google.com with SMTP id a62so11443937oib.1
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 19:51:51 -0700 (PDT)
In-Reply-To: <20160924.201054.1736819083455070537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/24/2016 05:10 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Sat, 24 Sep 2016 12:58:30 -0700
> 
>> There is already a commit:
>>
>> Revert "net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings"
>>
>> which should make this apply cleanly to "net" now.
> 
> But look at net-next, it got re-added there.
> 
> This is going to be a bit of a merge hassle, and this is why I pushed
> back on the other attempt to revert this thing.

OK, so how about this:

- this patch applies to net which should be okay for now
- to avoid future conflicts when you merge net into net-next, I submit a
revert of "net: ethernet: bcmgenet: use
phy_ethtool_{get|set}_link_ksettings" against net-next

Does that work for you?
