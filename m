From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by
 pci_match_id()
Date: Tue, 1 Apr 2014 09:41:10 +0800
Message-ID: <20140401014110.GA5883@richard>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
 <CAJZOPZ+je04BC8BAoL1i1jAGrMFbHkFSAjypFSd3Kxc6_PC-cw@mail.gmail.com>
 <20140331035439.GA11288@richard>
 <20140331.163240.1147956381197703417.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, or.gerlitz@gmail.com,
	amirv@mellanox.com, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	bhelgaas@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:46457 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbaDABlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 21:41:18 -0400
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 1 Apr 2014 11:41:16 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id EAAED2CE803F
	for <netdev@vger.kernel.org>; Tue,  1 Apr 2014 12:41:12 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s311KkHR5964274
	for <netdev@vger.kernel.org>; Tue, 1 Apr 2014 12:20:47 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s311fB1H020398
	for <netdev@vger.kernel.org>; Tue, 1 Apr 2014 12:41:12 +1100
Content-Disposition: inline
In-Reply-To: <20140331.163240.1147956381197703417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 04:32:40PM -0400, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Mon, 31 Mar 2014 11:54:39 +0800
>
>> On Sun, Mar 30, 2014 at 09:08:06PM +0300, Or Gerlitz wrote:
>>>On Sun, Mar 30, 2014 at 6:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
>>>> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>>>> pci_device_id.driver_data to __mlx4_init_one during reset".
>>>>
>>>> pci_match_id() might return NULL if someone binds the driver to a device
>>>> manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
>>>> before using it.
>>>>
>>>> Thanks to Bjorn who raised the problem.
>>>
>>>Well, that commit was applied to net and is now present in Linus
>>>tree... so assuming it's too late for 3.14, need to queue this for
>>>-stable
>>>
>>>Or.
>> 
>> Sorry for this bothering, hope this will not block someone.
>> 
>> Here is my suggestion for fixing this, not sure this is a good way to export
>> pci_match_device() to modules. This is my current solution to this problem. If
>> you have any comments, please let me know.
>
>This needs to be ACK'd by the PCI maintainers, please make sure they see this.

Yes, I think Bjorn, maintainers of PCI, is in the list.

Bjorn,

Do you have some concern on this implementation?
Or, you suggest me to send this to pci maillist too?

-- 
Richard Yang
Help you, Help me
