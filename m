From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Qlogic qla3xxx driver v2.02.00-k36 for upstream inclusion.
Date: Wed, 19 Jul 2006 16:41:09 -0400
Message-ID: <44BE98E5.7060207@garzik.org>
References: <1090CAF73D6FFE4EA45395454C82937B05214A4B@AVEXCH1.qlogic.org> <0BB3E5E7462EEA4295BC02D49691DC0705BC91@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:24204 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030299AbWGSUlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 16:41:15 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC0705BC91@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
>  
> Andrew,
> 
> Attached is a patch to the qla3xxx driver in your -mm test kernel.  This 
> patch makes the following changes:
> 
> -Removed potential infinite loop in ql_sem_spinlock().
> -Relaxed hardware locking granularity.
> -Fixed irq_request() where shared flag was used in MSI environment.
> -Removed queue containing TX control blocks. This resource has a one to 
> one  correspondence to each entry in the TX queue.
> -Removed unnecessary tx_lock.
> -Changed version to v2.02.00-k36.
> 
> The above changes plus the changes from the k35 patch address Jeff 
> Garzik's concerns from his response. His response can be reviewed at 
> this URL:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115101855424635&w=2 
> <http://marc.theaimsgroup.com/?l=linux-netdev&m=115101855424635&w=2>
> 
> 
> 
> This driver has been through several iterations on the netdev list and 
> we feel this driver is ready for inclusion in the upstream kernel.

Send me a patch via private email (for size reasons), include a proper 
Signed-off-by line per http://linux.yyz.us/patch-format.html and I will 
merge this driver straightaway.

	Jeff



