From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by
 pci_match_id()
Date: Mon, 31 Mar 2014 16:32:40 -0400 (EDT)
Message-ID: <20140331.163240.1147956381197703417.davem@davemloft.net>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
	<CAJZOPZ+je04BC8BAoL1i1jAGrMFbHkFSAjypFSd3Kxc6_PC-cw@mail.gmail.com>
	<20140331035439.GA11288@richard>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, amirv@mellanox.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, bhelgaas@google.com
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbaCaUcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:32:43 -0400
In-Reply-To: <20140331035439.GA11288@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Mon, 31 Mar 2014 11:54:39 +0800

> On Sun, Mar 30, 2014 at 09:08:06PM +0300, Or Gerlitz wrote:
>>On Sun, Mar 30, 2014 at 6:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
>>> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>>> pci_device_id.driver_data to __mlx4_init_one during reset".
>>>
>>> pci_match_id() might return NULL if someone binds the driver to a device
>>> manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
>>> before using it.
>>>
>>> Thanks to Bjorn who raised the problem.
>>
>>Well, that commit was applied to net and is now present in Linus
>>tree... so assuming it's too late for 3.14, need to queue this for
>>-stable
>>
>>Or.
> 
> Sorry for this bothering, hope this will not block someone.
> 
> Here is my suggestion for fixing this, not sure this is a good way to export
> pci_match_device() to modules. This is my current solution to this problem. If
> you have any comments, please let me know.

This needs to be ACK'd by the PCI maintainers, please make sure they see this.
