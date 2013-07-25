From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 0/3] export device physical port id to
 userspace
Date: Thu, 25 Jul 2013 09:41:12 +0200
Message-ID: <20130725074112.GA1621@minipsycho.brq.redhat.com>
References: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
 <20130724.160037.37317394789474047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37919 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab3GYHnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 03:43:24 -0400
Received: by mail-ee0-f46.google.com with SMTP id d41so721466eek.5
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 00:43:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130724.160037.37317394789474047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 25, 2013 at 01:00:37AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 22 Jul 2013 15:05:14 +0200
>
>> This patchset is based on patch by Narendra_K@Dell.com
>> Once device which can change phys port id during its lifetime adopts this,
>> NETDEV_CHANGEPHYSPORTID event will be added and driver will call
>> call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagate
>> the change to userspace.
>> 
>> v1->v2: as suggested by Ben, handle -EOPNOTSUPP in rtnl code (wrapped up ndo call)
>> v2->v3: adjusted patch 1 commit message
>
>As mentioned we'd like to have at least one driver implementing the new
>interface as part of the patch set.
>
>Once you have that sorted I think this is mostly ready.


Allright. Will repost with most probably igb/igbvf support implemented
as well. Thanks!
