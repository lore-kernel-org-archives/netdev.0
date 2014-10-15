From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 0/3] SCTP fixes
Date: Wed, 15 Oct 2014 16:20:31 -0400
Message-ID: <20141015202031.GA9310@localhost.localdomain>
References: <1412888133-833-1-git-send-email-dborkman@redhat.com>
 <20141014.124657.128658692728989163.davem@davemloft.net>
 <20141015030631.GA6778@localhost.localdomain>
 <20141015.002143.780696221161706737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43852 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaJOUUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 16:20:44 -0400
Content-Disposition: inline
In-Reply-To: <20141015.002143.780696221161706737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 12:21:43AM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 14 Oct 2014 23:06:32 -0400
> 
> > On Tue, Oct 14, 2014 at 12:46:57PM -0400, David Miller wrote:
> >> From: Daniel Borkmann <dborkman@redhat.com>
> >> Date: Thu,  9 Oct 2014 22:55:30 +0200
> >> 
> >> > Here are some SCTP fixes.
> >> > 
> >> > [ Note, immediate workaround would be to disable ASCONF (it
> >> >   is sysctl disabled by default). It is actually only used
> >> >   together with chunk authentication. ]
> >> 
> >> Series applied, thanks guys.
> > Why did you apply this Dave? There was ongoing discussion around it.
> 
> Sorry Neil, that wasn't my impression.
> 
> Worry not I can revert or apply relative fixes on top.
> :-)
> 
No, no worries, just trying to figure out how to inform admins of duplicate
ASCONF serial numbers.  A follow on patch to add pr_debugs will be easy here.
Neil

> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
