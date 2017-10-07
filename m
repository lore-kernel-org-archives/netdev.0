From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/6] mlxsw: Offload bridge device mrouter
Date: Sat, 07 Oct 2017 21:42:36 +0100 (WEST)
Message-ID: <20171007.214236.828908395863095403.davem@davemloft.net>
References: <20171005103642.1414-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdJGUmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 16:42:54 -0400
In-Reply-To: <20171005103642.1414-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  5 Oct 2017 12:36:36 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Yotam says:
> 
> Similarly to a bridged port, the bridge device itself can be configured by
> the user to be an mrouter port. In this case, all multicast traffic should
> be forwarded to it. Make the mlxsw Spectrum driver offload these directives
> to the Spectrum hardware.
> 
> Patches 1-3 add a new switchdev notification for bridge device mrouter
> port status and make the bridge module notify about it.
> 
> Patches 4-6 change the mlxsw Spectrum driver to handle these notifications
> by adding the Spectrum router port to the bridge MDB entries.

It looks like Nikolay wants some feedback addressed for patch #1.

Thanks.
