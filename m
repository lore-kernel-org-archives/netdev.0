From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [PATCH net-next] igb: Change how we check for pre-existing and
 assigned VFs
Date: Thu, 16 Aug 2012 07:05:03 +0200
Message-ID: <502C7F7F.1070101@kpanic.de>
References: <1345009886-29153-1-git-send-email-sassmann@kpanic.de> <502BCA89.1030900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	carolyn.wyborny@intel.com, gregory.v.rose@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from app1a.xlhost.de ([213.202.242.161]:37123 "EHLO app1a.xlhost.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab2HPFN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 01:13:26 -0400
In-Reply-To: <502BCA89.1030900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.08.2012 18:12, Alexander Duyck wrote:
> On 08/14/2012 10:51 PM, Stefan Assmann wrote:
>> Adapt the pre-existing and assigned VFs code to the ixgbe way introduced
>> in commit 9297127b9cdd8d30c829ef5fd28b7cc0323a7bcd.
>>
>> Instead of searching the enabled VFs we use pci_num_vf to determine enabled VFs.
>> By comparing to which PF an assigned VF is owned it's possible to decide
>> whether to leave it enabled or not.
>>
>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>

[...]

> 
> As the author of commit 9297127b9cdd8d30c829ef5fd28b7cc0323a7bcd it
> would have been nice to include me on the CC since I am probably one of
> the best people to review this patch.  That being said, the patch itself
> looks good.

Sorry, my mistake. I forgot to do that.

> 
> A follow-on patch that probably needs to be written would be to create a
> generic version of "vfs_are_assigned" as a part of the SR-IOV API.  That
> way we can avoid duplicating the function in each of the drivers.  All
> that would need to be changed is to pull the vendor ID from the pdev,
> and to pull the VF device ID from the SR-IOV configuration space of the
> physical function.  I'll try to get to that sometime in the next few
> weeks if nobody gets to it before I do.

Sounds like a good idea.

> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 

Thanks for the review!

  Stefan
