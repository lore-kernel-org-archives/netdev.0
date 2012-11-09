From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] netconsole: add oops_only module option
Date: Fri, 09 Nov 2012 11:02:32 +0800
Message-ID: <1352430152.8746.1.camel@cr0>
References: <1352382158-3928-1-git-send-email-amwang@redhat.com>
	 <509C0CCD.7020900@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337Ab2KIDCq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 22:02:46 -0500
In-Reply-To: <509C0CCD.7020900@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 11:49 -0800, Randy Dunlap wrote:
> On 11/08/2012 05:42 AM, Cong Wang wrote:
> 
> > Some people wants to log only oops messages via netconsole,
> > (this is also why netoops was invented)
> > so add a module option for netconsole. This can be tuned
> > via /sys/module/netconsole/parameters/oops_only at run time
> > as well.
> > 
> 
> 
> Hi,
> 
> What does this do with panics?
> Do they set oops_in_progress?

Yes, panic() calls bust_spinlocks(1).
