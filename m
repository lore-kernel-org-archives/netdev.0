From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 04/10] net: Add netif_is_vrf_master helper
Date: Mon, 13 Mar 2017 08:39:19 -0600
Message-ID: <d3d82369-bea2-ea7e-0912-66061bd6cc91@cumulusnetworks.com>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36327 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752313AbdCMOjY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 10:39:24 -0400
Received: by mail-it0-f53.google.com with SMTP id w124so13279011itb.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 07:39:24 -0700 (PDT)
In-Reply-To: <1489390713-2634-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/17 1:38 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Drivers capable of offloading VRF configurations need to know the ports
> are enslaved to an actual VRF device and not some other L3 master.
> 
> Add a flag to indicate netdev is a VRF master and a corresponding
> helper.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/vrf.c         | 2 +-
>  include/linux/netdevice.h | 8 ++++++++
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 

IFF_VRF_MASTER was renamed IFF_L3MDEV_MASTER 18 months ago.
