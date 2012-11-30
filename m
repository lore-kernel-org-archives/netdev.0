From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] smsc: RFC: Workaround for problems with lan8710 phy
 auto MDI-X
Date: Fri, 30 Nov 2012 19:14:40 +0000
Message-ID: <1354302880.2640.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <8D7E9026-6276-452B-9E0C-AEB8CF38C9FD@netconsequence.de>
	 <alpine.LNX.2.00.1211301622110.25639@pobox.suse.cz>
	 <20121130.122302.1825816242500143123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jkosina@suse.cz>, <pt@netconsequence.de>,
	<otavio@ossystems.com.br>, <javier@dowhile0.org>,
	<chohnstaedt@innominate.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38974 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992913Ab2K3TOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 14:14:47 -0500
In-Reply-To: <20121130.122302.1825816242500143123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 12:23 -0500, David Miller wrote:
> From: Jiri Kosina <jkosina@suse.cz>
> Date: Fri, 30 Nov 2012 16:23:30 +0100 (CET)
> 
> > Of course it'd be far better if faulty hardware can be autodetected in 
> > runtime.
> 
> That is how this must be handled.

Well, we also have the recent extension to ETHTOOL_SSET for forcing
MDI-X on or off.  If it's not possible to detect the faulty hardware
then the driver can implement this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
