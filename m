From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by pci_match_id()
Date: Mon, 31 Mar 2014 21:12:04 -0600
Message-ID: <CAErSpo4mjKB-nDDNb6BSMi1+BZ62jdvP_Rma2gc3DTF9-KkgMA@mail.gmail.com>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
 <CAJZOPZ+je04BC8BAoL1i1jAGrMFbHkFSAjypFSd3Kxc6_PC-cw@mail.gmail.com>
 <20140331035439.GA11288@richard> <20140331.163240.1147956381197703417.davem@davemloft.net>
 <20140401014110.GA5883@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, or.gerlitz@gmail.com,
	Amir Vadai <amirv@mellanox.com>,
	netdev <netdev@vger.kernel.org>, yevgenyp@mellanox.com
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33786 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbaDADMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 23:12:25 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so3138753igq.1
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 20:12:24 -0700 (PDT)
In-Reply-To: <20140401014110.GA5883@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 7:41 PM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
> On Mon, Mar 31, 2014 at 04:32:40PM -0400, David Miller wrote:
>>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>>Date: Mon, 31 Mar 2014 11:54:39 +0800
>>
>>> On Sun, Mar 30, 2014 at 09:08:06PM +0300, Or Gerlitz wrote:
>>>>On Sun, Mar 30, 2014 at 6:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
>>>>> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>>>>> pci_device_id.driver_data to __mlx4_init_one during reset".
>>>>>
>>>>> pci_match_id() might return NULL if someone binds the driver to a device
>>>>> manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
>>>>> before using it.
>>>>>
>>>>> Thanks to Bjorn who raised the problem.
>>>>
>>>>Well, that commit was applied to net and is now present in Linus
>>>>tree... so assuming it's too late for 3.14, need to queue this for
>>>>-stable
>>>>
>>>>Or.
>>>
>>> Sorry for this bothering, hope this will not block someone.
>>>
>>> Here is my suggestion for fixing this, not sure this is a good way to export
>>> pci_match_device() to modules. This is my current solution to this problem. If
>>> you have any comments, please let me know.
>>
>>This needs to be ACK'd by the PCI maintainers, please make sure they see this.
>
> Yes, I think Bjorn, maintainers of PCI, is in the list.
>
> Bjorn,
>
> Do you have some concern on this implementation?
> Or, you suggest me to send this to pci maillist too?

I haven't looked at the patch yet, but yes, please do copy linux-pci as well.
