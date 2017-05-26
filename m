From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 02/18] bridge: Export multicast enabled state
Date: Fri, 26 May 2017 11:56:24 +0300
Message-ID: <8ea5aaa4-b04e-b24c-850d-0bcbb0259842@cumulusnetworks.com>
References: <20170526063740.8909-1-jiri@resnulli.us>
 <20170526063740.8909-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:32867 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967663AbdEZI4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 04:56:11 -0400
Received: by mail-wm0-f54.google.com with SMTP id m7so4567418wmg.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 01:56:11 -0700 (PDT)
In-Reply-To: <20170526063740.8909-3-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/17 9:37 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> During enslavement to a bridge, after the CHANGEUPPER is sent, the
> multicast enabled state of the bridge isn't propagated down to the
> offloading driver unless it's changed.
> 
> This patch allows such drivers to query the multicast enabled state from
> the bridge, so that they'll be able to correctly configure their flood
> tables during port enslavement.
> 
> In case multicast is disabled, unregistered multicast packets can be
> treated as broadcast and be flooded through all the bridge ports.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>   include/linux/if_bridge.h | 5 +++++
>   net/bridge/br_multicast.c | 8 ++++++++
>   2 files changed, 13 insertions(+)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
