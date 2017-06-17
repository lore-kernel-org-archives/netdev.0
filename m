From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net 0/4] macvlan: Fix some issues with changing mac
 addresses
Date: Fri, 16 Jun 2017 22:23:41 -0700
Message-ID: <106769ec-3721-b461-43d4-65dea397a197@oracle.com>
References: <20170616133649.24622-1-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28774 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdFQFXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 01:23:47 -0400
In-Reply-To: <20170616133649.24622-1-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/16/17 6:36 AM, Vladislav Yasevich wrote:
> There are some issues in macvlan wrt to changing it's mac address.
> * An error is returned in the specified address is the same as an already
>   assigned address.
> * In passthru mode, the mac address of the macvlan device doesn't change.
> * After changing the mac address of a passthru macvlan and then removing it,
>   the mac address of the physical device remains changed.
>
> This patch series attempts to resolve these issues.
>
> Thanks
> -vlad
>
> Vladislav Yasevich (4):
>   macvlan: Do not return error when setting the same mac address
>   macvlan: Fix passthru macvlan mac address inheritance
>   macvlan: convert port passthru to flags.

Above 3 patches looks good to me, so

Reviewed-by: Girish Moodalbail <girish.moodalbail@oracle.com>


>   macvlan: Let passthru macvlan correctly restore lower mac address

However, I have few questions/comments on the above patch.

thanks,
~Girish

>
>  drivers/net/macvlan.c | 85 ++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 71 insertions(+), 14 deletions(-)
>
