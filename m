From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Pull request: sfc-next 2013-08-30
Date: Mon, 2 Sep 2013 18:20:13 +0100
Message-ID: <1378142413.1552.12.camel@bwh-desktop.uk.level5networks.com>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
	 <20130831.222857.845781578450355342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60449 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333Ab3IBRUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 13:20:17 -0400
In-Reply-To: <20130831.222857.845781578450355342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-31 at 22:28 -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 30 Aug 2013 04:36:34 +0100
> 
> > 1. A little more refactoring.
> > 2. Remove the unnecessary use of atomic_t that you pointed out.
> > 3. Add support for starting or queueing firmware requests from atomic
> > context.
> > 4. Add hwmon support for additional sensors found on some new boards.
> > 5. Add support for the EF10 controller architecture, the SFC9100 family
> > and specifically the SFC9120 controller.
> 
> Pulled, thanks Ben.
> 
> Maybe you can get away with just doing "atomic_inc_return()" for the
> MCDI sequence number bump and avoid the iface lock in those paths?

I haven't checked, but I think the spinlock will almost always be
uncontended.  It can bounce between CPUs, but then so will seqno.  So I
don't think that would make any significant difference to performance.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
