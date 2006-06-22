From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 18:21:37 -0400
Message-ID: <1151014897.5099.29.camel@jzny2>
References: <54AD0F12E08D1541B826BE97C98F99F15F55E2@NT-SJCA-0751.brcm.ad.broadcom.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:55203 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030424AbWFVWVj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 18:21:39 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtXYW-0002zw-DP
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 18:21:44 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F15F55E2@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-22-06 at 15:11 -0700, Caitlin Bestler wrote:
> netdev-owner@vger.kernel.org wrote:


> 
> These subscriptions are an attempt to cede full control
> of these issues back to one place, the kernel, and to
> guarantee that an offload device can never think that
> the route to to X is Y when the kernel says it is Z.
> Or that it has a different PMTU, etc.
> 

Ok, so it is the routing information then that you are syncing,
correct? 

> I don't have any strong opinion on the best mechanism
> for implementing these subscriptions, but having correct
> consistent networking behaviour depend on a user-mode
> relay strikes me as odd.
> 

And why does it sound odd? 
You will need to think about one issue:
Linux caches routing info - it is not just as simple as keeping track of
the FIB and somehow correlating that to the ARP entries.  

cheers,
jamal

