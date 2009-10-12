From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: [PATCH] netxen: fix pci bar mapping
Date: Sun, 11 Oct 2009 23:12:33 -0700
Message-ID: <4AD2C8D1.3020704@qlogic.com>
References: <1255315402-1578-1-git-send-email-dhananjay@netxen.com> <20091011.230656.245420067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:19230 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbZJLGN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 02:13:59 -0400
In-Reply-To: <20091011.230656.245420067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I am resending the patch.

Thanks,
Dhananjay

David Miller wrote:
> From: Dhananjay Phadke <dhananjay@netxen.com>
> Date: Sun, 11 Oct 2009 19:43:22 -0700
>
>> Use phys_addr_t data type for pci resource address
>> instead of unsigned long. This fixes mapping of
>> pci resources where resource addresses can be larger
>> than word size (e.g. PAE).
>>
>> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
>
> The correct type to use is 'resource_size_t' not 'phys_addr_t'.
>
> Look at the "struct resource" member types in linux/ioport.h, that's
> what these pci_resource_start() et al. routines return.
>
> Please fix this up and resubmit.

