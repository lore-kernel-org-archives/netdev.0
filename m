From: David Miller <davem@davemloft.net>
Subject: Re: net.ipv6.conf.INT.accept_ra_rt_info_max_plen defaults to 0
Date: Mon, 02 Feb 2009 21:36:16 -0800 (PST)
Message-ID: <20090202.213616.258001767.davem@davemloft.net>
References: <alpine.LRH.2.00.0902030632240.7583@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sega01@gmail.com
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45707
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751907AbZBCFgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 00:36:20 -0500
In-Reply-To: <alpine.LRH.2.00.0902030632240.7583@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Savola <pekkas@netcore.fi>
Date: Tue, 3 Feb 2009 06:38:49 +0200 (EET)

> As reported and discussed below and in
> <http://www.mail-archive.com/debian-ipv6@lists.debian.org/msg03753.html>,
> to accept "route information option" on Linux, you have to manually
> change accept_ra_rt_info_max_plen sysctl value.  Other
> implementations that I know of accept this by default.
>
> Is it intentional that Route Information options are ignored by default?
>
> I suspect not -- if so, the default value should be (IMHO) 64 or if
> that's disagreeable, 48.
> 
> Even if this is intentional, I think the intentions should be revisited.

It looks very intentional, both via the code and it's documentation
in ip-sysctl.txt

It seems that it is disabled like this by default when
accept_ra_rtr_pref is enabled, and that seems pretty reasonable to me.

I'm sure whoever made that decision didn't do so on a whim and had
a very good reason for it.
