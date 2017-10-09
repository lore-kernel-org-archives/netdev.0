From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/5] mlxsw: Offload bridge device mrouter
Date: Mon, 09 Oct 2017 10:18:28 -0700 (PDT)
Message-ID: <20171009.101828.1483628850783668385.davem@davemloft.net>
References: <20171009091535.1315-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754373AbdJIRSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:18:30 -0400
In-Reply-To: <20171009091535.1315-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  9 Oct 2017 11:15:30 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Yotam says:
> 
> Similarly to a bridged port, the bridge device itself can be configured by
> the user to be an mrouter port. In this case, all multicast traffic should
> be forwarded to it. Make the mlxsw Spectrum driver offload these directives
> to the Spectrum hardware.
> 
> Patches 1 and 2 add a new switchdev notification for bridge device mrouter
> port status and make the bridge module notify about it.
> 
> Patches 3-5 change the mlxsw Spectrum driver to handle these notifications
> by adding the Spectrum router port to the bridge MDB entries.
> 
> ---
> v1->v2:
>  - patch1:
>    - Don't add the MDB_RTR_TYPE_TEMP state and use the timer_pending to
>      distinguish between learning-on and learning-off states

Series applied, thank you.
