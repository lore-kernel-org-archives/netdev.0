From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] [PATCH 6/8] e1000e: convert ndev_ printks	to	something
 smaller
Date: Wed, 02 Apr 2008 11:55:46 -0700
Message-ID: <47F3D6B2.9070306@intel.com>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>	<20080328161531.6562.8515.stgit@localhost.localdomain>	<47EDA38F.6080301@garzik.org> <47F12F27.802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64175 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755108AbYDBS4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 14:56:30 -0400
In-Reply-To: <47F12F27.802@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Auke Kok wrote:
>>> From: Bruce Allan <bruce.w.allan@intel.com>
>>>
>>> The ndev_* printk's are too lenghty and we don't need to specify
>>> the adapter/netdev struct at all, making this a lot more readable.
>>>
>>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>> ---
>>>
>>>  drivers/net/e1000e/e1000.h   |   27 ++++----
>>>  drivers/net/e1000e/ethtool.c |   38 +++++------
>>>  drivers/net/e1000e/netdev.c  |  148 +++++++++++++++++++-----------------------
>>>  drivers/net/e1000e/param.c   |   31 +++------
>>>  4 files changed, 108 insertions(+), 136 deletions(-)
>> This stuff should just be removed.
>>
>> Either the code should be outputting "ethX: blahblah" via printk(), or 
>> the code should be outputting the standard dev_printk() prefix [driver 
>> name, PCI device info].
>>
>> Also, it is recommended to use the NETIF_MSG_xxx bits to permit 
>> fine-grained control over which messages are output, on a per-port basis 
>> (controlled via ethtool).  grep around for 'msg_enable'
> 
> yes and I even tried pushing for a generic netdev printk that incorporates the
> msg_enable bits properly
> 
> I also got absolutely unwelcome responses to that, if not none :)
> 
> once we get such a thing, we can incorporate this into e1000 with this patch by
> changing 2 lines. so I think this patch is still a good thing, and it certainly
> removes a lot of wrapped lines.

Jeff,

I'm not sure how to proceed with this mess cleanup so I'm removing that patch from
the series I sent, and I will revisit this issue later.

I'm resending the ones I have sent once but are on hold pending this discussion.
They are all meant for #upstream and should apply OK.

thanks,

Auke

