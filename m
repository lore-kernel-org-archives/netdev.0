From: David Arcari <darcari@redhat.com>
Subject: Re: [PATCH] net: ethernet: aquantia: set net_device mtu when mtu is
 changed
Date: Mon, 13 Mar 2017 11:50:50 -0400
Message-ID: <5a3a435e-2ea5-343b-49e9-aff185eb73cc@redhat.com>
References: <1489008801-120389-1-git-send-email-darcari@redhat.com>
 <20170312.230919.811312629901809185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel.Belous@aquantia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48620 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751409AbdCMPuu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 11:50:50 -0400
In-Reply-To: <20170312.230919.811312629901809185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2017 02:09 AM, David Miller wrote:
> From: David Arcari <darcari@redhat.com>
> Date: Wed,  8 Mar 2017 16:33:21 -0500
> 
>> When the aquantia device mtu is changed the net_device structure is not
>> updated.  As a result the ip command does not properly reflect the mtu change.
>>
>> Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
>> assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
>> has a ndo_change_mtu routine.
>>
>> Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")
>>
>> Cc: Pavel Belous <Pavel.Belous@aquantia.com>
>> Signed-off-by: David Arcari <darcari@redhat.com>
> 
> Applied, thanks.
> 

Hi David,

I see that my patch:

"net: ethernet: aquantia: call set_irq_affinity_hint before free_irq"

has been applied to net, but I don't see that this patch has been applied.

Is there any chance that you replied to the wrong patch?  Or am I missing something?

Thanks,

-Dave
