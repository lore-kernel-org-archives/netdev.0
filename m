From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [PATCH 2/4] [RFC] e1000: make ioport free for	supported
 devices
Date: Thu, 06 Mar 2008 11:35:17 -0800
Message-ID: <47D04775.7020002@intel.com>
References: <20080303223731.16344.94975.stgit@localhost.localdomain>	<20080303223737.16344.16498.stgit@localhost.localdomain> <47CE84BB.1010408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7542 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754092AbYCFTjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 14:39:41 -0500
In-Reply-To: <47CE84BB.1010408@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
>>
>> Most e1000 devices do not need ioport access to function properly.
>> This is desirable for a few massive homed systems where ioport
>> resources become constrained.
>>
>> This patch is based on the code from Tomohiro Kusumi, heavily
>> modified to fit PCI API changes and e1000 driver changes.
>>
>> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> I don't think you need pci_select_bars()?  It should just be 
> pci_enable_device_mem() in both paths AFAICS...

honestly I don't know :) - I'll look into it. if that's the case then the patch
will change significantly.

thanks,

Auke
