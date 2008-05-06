From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v2.6.26] ucc_geth: Fix arguments to dma map/unmap functions
Date: Tue, 6 May 2008 16:21:46 -0500
Message-ID: <DDDA7132-5D28-4C57-99A8-048A5C9A5291@freescale.com>
References: <1209751290-25557-1-git-send-email-afleming@freescale.com> <482084CA.70104@pobox.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:48754 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933431AbYEFVWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 17:22:54 -0400
In-Reply-To: <482084CA.70104@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 6, 2008, at 11:18, Jeff Garzik wrote:

> Andy Fleming wrote:
>> We were passing NULL as the device.  When we actually start  
>> supporting
>> more interesting memory configurations, this will break things, so
>> we proactively are fixing the bug.
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> ---
>> drivers/net/ucc_geth.c |    9 +++++----
>> 1 files changed, 5 insertions(+), 4 deletions(-)
>
> ACK but failed to apply


Hmm...I think I got my patches sent out in the wrong order.  I think  
if you try this patch again, it will apply, now that you've applied  
the ucc_geth sparse patch.  I just rebased my tree against netdev/ 
upstream, and it applies without any problems.  Sorry, next time I'll  
make sure to number my patches when there's a dependency.

Andy
