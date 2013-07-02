From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: rtnl_lock deadlock on 3.10
Date: Tue, 2 Jul 2013 10:28:18 +0200
Message-ID: <20130702082818.GA26178@order.stressinduktion.org>
References: <20130701145456.GA7756@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:49379 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932257Ab3GBI2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:28:20 -0400
Content-Disposition: inline
In-Reply-To: <20130701145456.GA7756@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 09:54:56AM -0500, Shawn Bohrer wrote:
> I've managed to hit a deadlock at boot a couple times while testing
> the 3.10 rc kernels.  It seems to always happen when my network
> devices are initializing.  This morning I updated to v3.10 and made a
> few config tweaks and so far I've hit it 4 out of 5 reboots.  It looks
> like most processes are getting stuck on rtnl_lock.  Below is a boot
> log with the soft lockup prints.  Please let know if there is any
> other information I can provide:

Could you try a build with CONFIG_LOCKDEP enabled?

Thanks,

  Hannes
