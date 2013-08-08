From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH V2 0/4] Enable bus master till the FLR completes for Chelsio
 T4
Date: Wed, 07 Aug 2013 17:11:26 -0700
Message-ID: <5202E22E.4070408@chelsio.com>
References: <1375784319-25760-1-git-send-email-vipul@chelsio.com> <20130807.170836.1214269360365516393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vipul@chelsio.com, linux-pci@vger.kernel.org, bhelgaas@google.com,
	tomreu@chelsio.com, divy@chelsio.com, dm@chelsio.com,
	nirranjan@chelsio.com, eilong@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20130807.170836.1214269360365516393.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 08/07/13 17:08, David Miller wrote:
> From: Vipul Pandya <vipul@chelsio.com>
> Date: Tue,  6 Aug 2013 15:48:35 +0530
>
>> This patch series adds device specific reset method for Chelsio T4 adapters.
>>
>> The series also adds new routine, pci_wait_for_pending_transaction, to wait for
>> pending pci transaction. There are few places where waiting for pending pci
>> transaction code was duplicated. This patch series also replaces occurances of
>> duplicate code.
>>
>> This patch series is built against Bjorn Helgaas pci tree next branch. We would
>> like to merge this series via the same.
>>
>> I have Cced respective maintainers of the modified drivers. Kindly review and
>> let us know in case of any review comments.
> Please push this via the PCI tree, and for the networking bits you can add:
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
> Thanks.

Thanks David.  I ~think~ that's covered and we've already gone through 
one round of reviews that Bjorn Helgaas graciously provided.

Note that this patch should also obviate the need for the patch which we 
attempted to get into the Chelsio T4 network driver cxgb4 several months 
ago which monitored the chip for a hang caused by KVM detaching a T4 
Virtual Function from a Virtual Machine.  You were unhappy with that 
patch and requested that we approach the problem differently.  Thanks 
for your push.

Casey
