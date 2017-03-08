From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next 0/5] sunvnet: better connection management
Date: Wed, 8 Mar 2017 15:04:45 -0800
Message-ID: <80e05f39-ea92-bfdf-b7d6-2cee47c8bab6@oracle.com>
References: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20282 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbdCHXHw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 18:07:52 -0500
In-Reply-To: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/6/2017 3:15 PM, Shannon Nelson wrote:
> These patches remove some problems in handling of carrier state
> with the ldmvsw vswitch, remove  an xoff misuse in sunvnet, and
> add stats for debug and tracking of point-to-point connections
> between the ldom VMs.

Further testing shows a problem in one of the patches, so there will be 
a V2 coming.

Thanks,
sln

>
> Shannon Nelson (5):
>   ldmvsw: better use of link up and down on ldom vswitch
>   sunvnet: add stats to track ldom to ldom packets and bytes
>   sunvnet: track port queues correctly
>   sunvnet: count multicast packets
>   sunvnet: xoff not needed when removing port link
>
>  drivers/net/ethernet/sun/ldmvsw.c         |   10 ++-
>  drivers/net/ethernet/sun/sunvnet.c        |  114 +++++++++++++++++++++++++++++
>  drivers/net/ethernet/sun/sunvnet_common.c |   50 +++++++++++--
>  drivers/net/ethernet/sun/sunvnet_common.h |   26 ++++--
>  4 files changed, 180 insertions(+), 20 deletions(-)
>
