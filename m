From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH rdma-next 13/19] RDMA/netlink: Add netlink device definitions to UAPI
Date: Wed, 21 Jun 2017 09:21:12 -0500
Message-ID: <022e01d2ea99$a2594160$e70bc420$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-14-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma@vger.kernel.org>,
        "'Chien Tin Tung'" <chien.tin.tung@intel.com>,
        "'Stephen Hemminger'" <stephen@networkplumber.org>,
        "'Jiri Pirko'" <jiri@mellanox.com>,
        "'Ariel Almog'" <ariela@mellanox.com>,
        "'Linux Netdev'" <netdev@vger.kernel.org>,
        "'Leon Romanovsky'" <leonro@mellanox.com>
To: "'Leon Romanovsky'" <leon@kernel.org>,
        "'Doug Ledford'" <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:52638 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751041AbdFUOVJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 10:21:09 -0400
In-Reply-To: <20170621060528.3752-14-leon@kernel.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Leon Romanovsky <leonro@mellanox.com>
> 
> Introduce new defines to rdma_netlink.h, so the RDMA configuration tool
> will be able to communicate with RDMA subsystem by using the shared defines.
> 
> The addition of new client (NLDEV) revealed the fact that we exposed by
> mistake the RDMA_NL_I40IW define which is not backed by any RDMA netlink
> by now and it won't be exposed in the future too. So this patch reuses
> the value and leaves the comment together with old definition to whose
> who are using RDMA_NL_I40IW as a replacement for digit "5".
> 
> The NLDEV operates with objects. The struct ib_device has two straightforward
> objects: device itself and ports of that device.
> 
> This brings us to propose the following commands to work on those objects:
>  * RDMA_NLDEV_CMD_{GET,SET,NEW,DEL} - works on ib_device itself
>  * RDMA_NLDEV_CMD_PORT_{GET,SET,NEW,DEL} - works on ports of specific
> ib_device
> 
> Those commands receive/return the device name
> (RDMA_NLDEV_ATTR_DEV_NAME)
> and port index (RDMA_NLDEV_ATTR_PORT_INDEX). For device object accesses,
> the RDMA_NLDEV_ATTR_PORT_INDEX will return the maximum number of ports
> for specific ib_device and for port access the actual port index.
> 
> The port index starts from 1 to follow RDMA/core internal semantics and
> the sysfs exposed knobs..
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

Reviewed-by: Steve Wise <swise@opengridcomputing.com>
