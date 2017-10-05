From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 3/6] net: bridge: Export bridge multicast router
 state
Date: Thu, 5 Oct 2017 16:09:26 +0300
Message-ID: <7e4f99be-647f-8ed6-8285-bb3cea8483eb@cumulusnetworks.com>
References: <20171005103642.1414-1-jiri@resnulli.us>
 <20171005103642.1414-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        andrew@lunn.ch, stephen@networkplumber.org, nbd@nbd.name,
        roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:43120 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdJENJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 09:09:30 -0400
Received: by mail-lf0-f53.google.com with SMTP id o125so12301234lfe.0
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 06:09:30 -0700 (PDT)
In-Reply-To: <20171005103642.1414-4-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/17 13:36, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Add an access function that, given a bridge netdevice, returns whether the
> bridge device is currently an mrouter or not. The function uses the already
> existing br_multicast_is_router function to check that.
> 
> This function is needed in order to allow ports that join an already
> existing bridge to know the current mrouter state of the bridge device.
> Together with the bridge device mrouter ports switchdev notifications, it
> is possible to have full offloading of the semantics of the bridge device
> mcast router state.
> 
> Due to the fact that the bridge multicast router status can change in
> packet RX path, take the multicast_router bridge spinlock to protect the
> read.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/if_bridge.h |  5 +++++
>  net/bridge/br_multicast.c | 12 ++++++++++++
>  2 files changed, 17 insertions(+)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
