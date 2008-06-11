From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 13:14:49 +0000
Message-ID: <20080611131449.GD4171@ff.dom.local>
References: <20080610.224023.116817726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:19756 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbYFKNKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 09:10:45 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2165486ika.5
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 06:10:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080610.224023.116817726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-06-2008 07:40, David Miller wrote:
...
> cassini: Does flush_scheduled_work() from ->change_mtu() method, which
> 	 also holds RTNL semaphore.  Seems tricky to fix as it's trying
> 	 to schedule work and then immediately wait for it to
> 	 complete synchronously before returning from the ->change_mtu
> 	 method.  Maybe calling cas_reset_task() directly would work,
> 	 but this could conflict with reset tasks scheduled in other
> 	 contexts.  NOT FIXED

Could you give an example of such a conflict? (I wonder how it's
avoided with current solution.)

Jarek P.
