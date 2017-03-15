From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] net: ethernet: aquantia: set net_device mtu when mtu is
 changed
Date: Wed, 15 Mar 2017 16:49:51 -0400
Message-ID: <33753b9a-8e76-f178-5eb4-a148ab2a683e@redhat.com>
References: <1489008801-120389-1-git-send-email-darcari@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Belous <Pavel.Belous@aquantia.com>
To: David Arcari <darcari@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60378 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751183AbdCOUtw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 16:49:52 -0400
In-Reply-To: <1489008801-120389-1-git-send-email-darcari@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-08 4:33 PM, David Arcari wrote:
> When the aquantia device mtu is changed the net_device structure is not
> updated.  As a result the ip command does not properly reflect the mtu change.
>
> Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
> assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
> has a ndo_change_mtu routine.
>
> Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")
>
> Cc: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: David Arcari <darcari@redhat.com>

Looks like an appropriate and necessary fix to me.

Reviewed-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
