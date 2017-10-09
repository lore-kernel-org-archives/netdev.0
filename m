From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 1/5] net: bridge: Notify on bridge device
 mrouter state changes
Date: Mon, 9 Oct 2017 13:52:30 +0300
Message-ID: <86ecac08-de7c-c36a-ed58-ee4782cbf7bc@cumulusnetworks.com>
References: <20171009091535.1315-1-jiri@resnulli.us>
 <20171009091535.1315-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        andrew@lunn.ch, stephen@networkplumber.org, nbd@nbd.name,
        roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:52751 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdJIKwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 06:52:34 -0400
Received: by mail-wm0-f51.google.com with SMTP id k4so22229310wmc.1
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 03:52:33 -0700 (PDT)
In-Reply-To: <20171009091535.1315-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/17 12:15, Jiri Pirko wrote:
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
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - use the timer_pending to distinguish between learning-on and
>    learning-off states
> ---
>  include/net/switchdev.h   |  1 +
>  net/bridge/br_multicast.c | 38 +++++++++++++++++++++++++++++++++++---
>  2 files changed, 36 insertions(+), 3 deletions(-)
> 

Much simpler, I like it. Thanks!

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
