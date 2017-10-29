From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: get rid of false alarm "Unknown cmd
 27" in dmesg
Date: Sun, 29 Oct 2017 12:13:50 +0900 (KST)
Message-ID: <20171029.121350.1610829940742409081.davem@davemloft.net>
References: <20171027213703.GA1107@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbdJ2DNz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 23:13:55 -0400
In-Reply-To: <20171027213703.GA1107@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 27 Oct 2017 14:37:03 -0700

> Creating a macvtap interface with the liquidio VF driver as lower device
> causes this alarming message to show up in dmesg:
> 
>     liquidio_link_ctrl_cmd_completion Unknown cmd 27
> 
> That's actually a false alarm because cmd 27 is the value of the macro
> OCTNET_CMD_SET_UC_LIST which is known.  It's a control command sent from
> host to NIC firmware to set the unicast MAC address list of the macvtap
> lower device.
> 
> Make the false alarm go away by adding a case for OCTNET_CMD_SET_UC_LIST
> in liquidio_link_ctrl_cmd_completion().
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>

Applied.
