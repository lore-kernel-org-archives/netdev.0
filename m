From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.0.y 0/3] rtnetlink: Fix problem with buffer allocation
Date: Thu, 03 Jan 2013 16:36:14 -0800 (PST)
Message-ID: <20130103.163614.162474717714949991.davem@davemloft.net>
References: <1357259449.2685.60.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, gregory.v.rose@intel.com,
	stable@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab3ADAgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 19:36:16 -0500
In-Reply-To: <1357259449.2685.60.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 4 Jan 2013 00:30:49 +0000

> These patches fix the problem that interface information including many
> VFs is too large for the 4K buffers used by glibc and other clients.
> This breaks many network services.
> 
> The first of these ('rtnetlink: Compute and store minimum ifinfo dump
> size') went into 3.1 and has also been included in SLE11 SP2.  The
> second and third were acked by David Miller and included in 3.2.34.
> 
> I've applied and briefly tested these changes in conjunction with a
> backport of the sfc driver to SLE11 SP3.

I'm fine with these going into 3.0.x-stable, thanks for doing the
backport.
