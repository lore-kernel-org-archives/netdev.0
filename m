From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Wed, 14 Nov 2007 08:59:45 -0700
Message-ID: <m1mytg24y6.fsf@ebiederm.dsl.xmission.com>
References: <200711131129.58868.borntraeger@de.ibm.com>
	<20071113.024500.155458534.davem@davemloft.net>
	<20071114021131.GB2523@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, borntraeger@de.ibm.com,
	netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:53445 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283AbXKNQBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 11:01:38 -0500
In-Reply-To: <20071114021131.GB2523@verge.net.au> (Simon Horman's message of
	"Tue, 13 Nov 2007 18:12:18 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman <horms@verge.net.au> writes:
>
> Hi Christian, Hi Dave,
>
> I have indeed been looking into this of late. Assuming that you use of
> CTL_UNNUMBERED is correct, this patch looks fine to me.  Acked.
>
> I was planning to do the same and also switch over all the other entries
> over to use CTL_UNNUMBERED, as its hard to imagine that anyone is using
> the sys_sysctl interface to IPVS.
>
> As for the commented out entries. They are supposed to be exposed by
> some other means - I believe the thinking was to comply with the don't
> expose stuff in proc any more idea. Where is the best place to expose
> this kind of stuff?
>
> Lastly, as Dave mentions, I'm travelling this week, so please
> excuse any slowness.


Looking at this patch it looks sane enough. Either removing ctl_name
or explicitly using CTL_UNNUMBERED is fine.  It may be wise to leave
the binary entries in ip_vs.h and sysctl_check.c as documentation,
but even there it doesn't much matter since we don't plan on adding more.

Eric
