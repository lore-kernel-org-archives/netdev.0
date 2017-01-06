From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv1 7/7] IPVTAP: IP-VLAN based tap driver
Date: Fri, 06 Jan 2017 15:14:03 -0800
Message-ID: <1483744443.9712.45.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483742009-19184-1-git-send-email-sainath.grandhi@intel.com>
         <1483742009-19184-8-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: Sainath Grandhi <sainath.grandhi@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32781 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755753AbdAFXOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 18:14:05 -0500
In-Reply-To: <1483742009-19184-8-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-06 at 14:33 -0800, Sainath Grandhi wrote:
> This patch adds a tap character device driver that is based on the
> IP-VLAN network interface, called ipvtap. An ipvtap device can be created
> in the same way as an ipvlan device, using 'type ipvtap', and then accessed
> using the tap user space interface.
> 
> Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
> Tested-by: Sainath Grandhi <sainath.grandhi@intel.com>
> ---


> +module_exit(ipvtap_exit);
> +MODULE_ALIAS_RTNL_LINK("ipvtap");
> +MODULE_AUTHOR("Arnd Bergmann <arnd@arndb.de>");
> +MODULE_LICENSE("GPL");

Who wrote this driver exactly ???
