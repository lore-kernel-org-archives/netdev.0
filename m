From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Thu, 08 Aug 2013 19:54:24 -0700
Message-ID: <1376016864.2087.34.camel@joe-AO722>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	 <20130808210918.GE5502@mwanda>
	 <20130808.142054.1541424422807503741.davem@davemloft.net>
	 <1375997625.2087.14.camel@joe-AO722> <520452F4.2070804@gmail.com>
	 <1376015984.2087.31.camel@joe-AO722> <520457AD.9060508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dan.carpenter@oracle.com,
	emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Kumar Gaurav <kumargauravgupta3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47085 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758252Ab3HICy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 22:54:26 -0400
In-Reply-To: <520457AD.9060508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 08:15 +0530, Kumar Gaurav wrote:
> On Friday 09 August 2013 08:09 AM, Joe Perches wrote:
[]
> > And, maybe it'd be better to use IRQF_TRIGGER_NONE
> > instead of 0.
> I tried googling what to replace IRQF_DISABLED with but found nothing. 
> In the patch fixed earlier (not by me) it was replaced with 0 so i did 
> same. But from now on I'll use IRQF_TRIGGER_NONE. Thanks

Maybe that's not the right thing to do.
0 is what's almost exclusively used.
IRQF_TRIGGER_NONE is only used a few times.
It's also a lot longer.
