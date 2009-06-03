From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: Addition of new device id (resend without
 pci_ids.h)
Date: Wed, 03 Jun 2009 12:24:37 -0400
Message-ID: <4A26A3C5.5030607@nvidia.com>
References: <4A269F6C.7030300@nvidia.com> <20090603.144456.01215273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "manfred@colorfullife.com" <manfred@colorfullife.com>,
	"akpm@osdl.org" <akpm@osdl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:7412 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbZFCV5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:57:02 -0400
In-Reply-To: <20090603.144456.01215273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> Date: Wed, 03 Jun 2009 12:06:04 -0400
> 
> 
>>Add support for new ethernet device in the MCP89 chipset.
>>
>>Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> Just use the constant directly, please :-)

But there is place in the patch that refers to device id so it makes 
more sense to have a macro. i.e

+       if (np->device_id != PCI_DEVICE_ID_NVIDIA_NVENET_40)

other places in the code also refer to device ids for certain 
workarounds. i.e.

		if ((id->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
		     id->device == PCI_DEVICE_ID_NVIDIA_NVENET_13) &&



> 
> The new macro is completely superfluous.
> 
> Trust me, other drivers just use the PCI ID constant directly in their
> tables too, and no animals were harmed by the experiment :-)
