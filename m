From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 16 Oct 2009 16:33:13 +0100
Message-ID: <1255707193.2869.12.camel@achroite>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091013150839.GD32107@ldl.fc.hp.com>
	 <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com>
	 <20091013173638.GE1119@ldl.fc.hp.com>
	 <20091016003245.GD29672@ldl.fc.hp.com>
	 <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com>
	 <20091016152053.GA9862@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com
To: dann frazier <dannf@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11397 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759462AbZJPPdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 11:33:53 -0400
In-Reply-To: <20091016152053.GA9862@ldl.fc.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-16 at 09:20 -0600, dann frazier wrote:
> On Fri, Oct 16, 2009 at 07:32:50PM +0530, Narendra_K@Dell.com wrote:
[...]
> > And how would the regular file look like in terms of holding ifindex of
> > the interface, which can be passed to libnetdevname.
> 
> I can't think of anything we need to store in the regular file. If we
> have the kernel name for the device, we can look up the ifindex in
> /sys. Correct me if I'm wrong, but storing it ourselves seems
> redundant.

But the name of a netdev can change whereas its ifindex never does.
Identifying netdevs by name would require additional work to update the
links when a netdev is renamed and would still be prone to race
conditions.  This is why Narendra and Matt were proposing to store the
ifindex in the node all along...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

