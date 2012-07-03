From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Tue, 3 Jul 2012 02:50:52 +0100
Message-ID: <1341280252.2590.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	  <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
	 <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
	 <4FF1A2DF.5090403@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, Hadar Hen Zion <hadarh@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54921 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932139Ab2GCBu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 21:50:56 -0400
In-Reply-To: <4FF1A2DF.5090403@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 16:32 +0300, Or Gerlitz wrote:
[...]
> > Also, are the rules really prioritised by location, so that if rule 0
> > and 1 match a packet then only rule 0 is applied?  If they are actually
> > prioritised by the match type then you need to assign locations on the
> > driver side that reflect the actual priorities.
> 
> 
> Rules are prioritized by a scheme made of "domain" X location, see below 
> and in patch #6
> the MLX4_DOMAIN_yyy entries, higher domain value means lower priority, 
> so for instance rules
> placed by ethtool would have higher priority over rules added by the L2 
> NIC  or by future RFS
> patch. Within a domain, the location matters.
> 
> You can see that simple L2 rules (e.g contain dest-mac, possibly vlan) 
> added by the driver
> use the NIC domain, wheres those added to serve ethtool commands use the 
> ETHTOOL one.
> 
> Within the ethtool domain, we maintain the priority as the location 
> specified by the user, hope this explains
> things.
[...]

Good, I didn't read the other patches but just wanted to make sure you
had thought about this.

Ben

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
