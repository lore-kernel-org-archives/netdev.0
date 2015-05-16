From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] pci: Add Cavium PCI vendor id
Date: Sat, 16 May 2015 17:14:44 -0400 (EDT)
Message-ID: <20150516.171444.245757401088795324.davem@davemloft.net>
References: <1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com>
	<1431747401-20847-2-git-send-email-aleksey.makarov@auriga.com>
	<CAErSpo4fLHEu_NOuy9CkrS9DOfSyCOkddPHEQz=pp6et8wa2AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aleksey.makarov@auriga.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, david.daney@cavium.com,
	linux-pci@vger.kernel.org
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbEPVOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 17:14:45 -0400
In-Reply-To: <CAErSpo4fLHEu_NOuy9CkrS9DOfSyCOkddPHEQz=pp6et8wa2AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Sat, 16 May 2015 09:49:40 -0500

> Hi Aleksey,
> 
> On Fri, May 15, 2015 at 10:36 PM, Aleksey Makarov
> <aleksey.makarov@auriga.com> wrote:
>> Signed-off-by: Aleksey Makarov <aleksey.makarov@auriga.com>
>> ---
>>  include/linux/pci_ids.h | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
>> index e63c02a..3633cc6 100644
>> --- a/include/linux/pci_ids.h
>> +++ b/include/linux/pci_ids.h
>> @@ -2327,6 +2327,8 @@
>>  #define PCI_DEVICE_ID_ALTIMA_AC9100    0x03ea
>>  #define PCI_DEVICE_ID_ALTIMA_AC1003    0x03eb
>>
>> +#define PCI_VENDOR_ID_CAVIUM           0x177d
> 
> Please read the note at the top of include/linux/pci_ids.h.  If this
> definition is used in two or more drivers, mention that in the
> changelog.  Otherwise, just use the bare hex value or a private
> #define in your driver.

It is referenced from two foo.c files in the same driver.

I don't know what policy we want for situations like that.
