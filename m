From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH v2] net: implement mechanism for HW based
 QOS
Date: Mon, 20 Dec 2010 14:58:44 -0800
Message-ID: <20101220145844.35c4de44@nehalam>
References: <20101217165622.26608.24819.stgit@jf-dev1-dcblab>
	<1292885287.3055.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, hadi@cyberus.ca, tgraf@infradead.org,
	eric.dumazet@gmail.com, nhorman@tuxdriver.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48867 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757821Ab0LTW6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 17:58:46 -0500
In-Reply-To: <1292885287.3055.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Dec 2010 22:48:07 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> > +	u8 num_tc;
> > +	struct netdev_tc_txq tc_to_txq[16];
> > +	u8 prio_tc_map[16];  
> 
> That seems like a fair amount of data to add to every net device,
> considering that users may create e.g. a lot of VLAN devices and they
> won't use this state at all.  Have you considered putting these in a
> structure that is accessed indirectly?

The tc stuff should use indirection and only allocate if needed.

-- 
