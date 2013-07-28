From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 0/4] export device physical port id to
 userspace
Date: Sun, 28 Jul 2013 13:15:31 -0700 (PDT)
Message-ID: <20130728.131531.1999841614812208345.davem@davemloft.net>
References: <1374840596-5748-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab3G1UPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 16:15:32 -0400
In-Reply-To: <1374840596-5748-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 26 Jul 2013 14:09:52 +0200

> This patchset is based on patch by Narendra_K@Dell.com
> Once device which can change phys port id during its lifetime adopts this,
> NETDEV_CHANGEPHYSPORTID event will be added and driver will call
> call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagate
> the change to userspace.

I'm generally fine with these patches, but some things still need to be
done.

First of all, I want a real comprehensive description of this patch
series in the "0/4" posting.

It should answer, in detail, the following questions:

1) Why do we need this, and why do existing facilities fail to provide
   a way to accomplish this?

2) Why is the physical port ID defined as a 32 byte opaque cookie?
   What formats and layouts need to be accomodated, and which
   influenced the design of the ID?

3) Are IDs globally unique?  Why or why not?  If IDs should be
   globally unique, but only in certain cases, what exactly are those
   cases.

And please address Ben's concerns about global uniqueness in the
igb/igbvf changes, and whether a 32-bit value is sufficient.

Thanks.
