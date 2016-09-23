From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] Mellanox 100G SRIOV offloads vlan push/pop
Date: Fri, 23 Sep 2016 07:22:42 -0400 (EDT)
Message-ID: <20160923.072242.1517007394054835660.davem@davemloft.net>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, hadarh@mellanox.com,
        jiri@mellanox.com, gospo@cumulusnetworks.com,
        jesse.brandeburg@intel.com, john.r.fastabend@intel.com,
        amirv@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51308 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932127AbcIWLWr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 07:22:47 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 22 Sep 2016 20:01:40 +0300

> From Or Gerlitz:
> 
> This series further enhances the SRIOV TC offloads of mlx5 to handle
> the TC vlan push and pop actions. This serves a common use-case in
> virtualization systems where the virtual switch add (push) vlan tags
> to packets sent from VMs and removes (pop) vlan tags before the packet
> is received by the VM. We use the new E-Switch switchdev mode and the
> TC vlan action to achieve that also in SW defined SRIOV environments by
> offloading TC rules that contain this action along with forwarding
> (TC mirred/redirect action) the packet.
> 
> In the first patch we add some helpers to access the TC vlan action info
> by offloading drivers. The next five patches don't add any new functionality,
> they do some refactoring and cleanups in the current code to be used next.
> 
> The seventh patch deals with supporting vlans by the mlx5 e-switch in switchdev
> mode. The eighth patch does the vlan action offload from TC and the last patch
> adds matching for vlans as typically required by TC flows that involve vlan
> pop action.
> 
> The series was applied on top of commit 524605e "cxgb4: Convert to use simple_open()"

Series applied, thanks.
