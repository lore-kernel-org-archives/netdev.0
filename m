From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 2/6] net: bridge: Notify on bridge device mrouter
 state changes
Date: Thu, 5 Oct 2017 16:11:14 +0300
Message-ID: <6f3808ff-5352-704d-3882-d97b9da6404c@cumulusnetworks.com>
References: <20171005103642.1414-1-jiri@resnulli.us>
 <20171005103642.1414-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        andrew@lunn.ch, stephen@networkplumber.org, nbd@nbd.name,
        roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:57180 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdJENLS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 09:11:18 -0400
Received: by mail-lf0-f41.google.com with SMTP id 90so8720915lfs.13
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 06:11:17 -0700 (PDT)
In-Reply-To: <20171005103642.1414-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/17 13:36, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Add the SWITCHDEV_ATTR_ID_BRIDGE_MROUTER switchdev notification type, used
> to indicate whether the bridge is or isn't mrouter. Notify when the bridge
> changes its state, similarly to the already existing bridged port mrouter
> notifications.
> 
> The notification uses the switchdev_attr.u.mrouter boolean flag to indicate
> the current bridge mrouter status. Thus, it only indicates whether the
> bridge is currently used as an mrouter or not, and does not indicate the
> exact mrouter state of the bridge (learning, permanent, etc.).
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/switchdev.h   |  1 +
>  net/bridge/br_multicast.c | 21 ++++++++++++++++++++-
>  2 files changed, 21 insertions(+), 1 deletion(-)
> 

LGTM, but if we switch to using the timer state it will need some adjustment.
Anyway for this version,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
