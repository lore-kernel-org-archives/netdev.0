From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Wed, 20 May 2015 10:37:16 -0400
Message-ID: <20150520143715.GM9559@gospo.home.greyhouse.net>
References: <555AD11E.5040709@cumulusnetworks.com>
 <20150519.123418.481170679256206928.davem@davemloft.net>
 <20150519194731.GK9559@gospo.home.greyhouse.net>
 <20150519.162845.955021778058631119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, john.r.fastabend@intel.com,
	sfeldma@gmail.com, john.fastabend@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33135 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbbETOhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:37:19 -0400
Received: by qkgv12 with SMTP id v12so32955202qkg.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 07:37:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150519.162845.955021778058631119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 04:28:45PM -0400, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Tue, 19 May 2015 15:47:32 -0400
> 
> > Are you actually saying that if users complain loudly enough about
> > the current behavior (not the change Roopa has proposed) that you
> > would be open to considering a change the current behavior?
> 
> I am saying that we have a contract with users not to break existing
> behavior.  Full stop.

I stepped away from the ledge and now definitely agree that the default
behavior should stay the same in the offload or non-offload case.

There is probably room for some level of notification (even if just a
printk) to let one know that offloading is disabled and it would be
great if there was a way to set fib_offload_disabled to false again, but
that's not going to happen until patches are submitted, so I'll get to
that instead of complaining more.  :-)
