From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6 v4] bonding: allow arp_ip_targets on
	separate vlans to use arp validation
Date: Mon, 28 Dec 2009 10:26:32 -0500
Message-ID: <20091228152632.GA6490@gospo.rdu.redhat.com>
References: <20091209220131.GO1639@gospo.rdu.redhat.com> <32269.1260508632@death.nxdomain.ibm.com> <20091214204858.GP1639@gospo.rdu.redhat.com> <20091225.182230.183058983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy@greyhouse.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbZL1P0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 10:26:42 -0500
Content-Disposition: inline
In-Reply-To: <20091225.182230.183058983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 25, 2009 at 06:22:30PM -0800, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Mon, 14 Dec 2009 15:48:58 -0500
> 
> > [PATCH net-next-2.6 v4] bonding: allow arp_ip_targets on separate vlans to use arp validation
>  ...
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> What is the status of this patch?

Dave,

This patch should be ready for inclusion.

I've addressed Jay's concerns related tcpdumps on the various
interfaces, so that there is no difference between the way things behave
before and after the patch.

I also addressed Eric's concerns regarding the liability of calling
__dev_get_by_index and switched to the shiny, new dev_get_by_index_rcu.

A backported version has also seen some testing on a 2.6.18-based kernel
and the results have been positive.

Thanks for following up,

-andy

