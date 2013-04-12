From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] ptp: dynamic allocation of PHC char devices
Date: Fri, 12 Apr 2013 18:23:09 -0400 (EDT)
Message-ID: <20130412.182309.709108913993113051.davem@davemloft.net>
References: <bb5ff20a9968a810e6f827921e56fc8fc8fededf.1365764133.git.jbenc@redhat.com>
	<20130412174802.GA6902@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, bhutchings@solarflare.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3DLWXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 18:23:11 -0400
In-Reply-To: <20130412174802.GA6902@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 12 Apr 2013 19:48:02 +0200

> On Fri, Apr 12, 2013 at 12:56:15PM +0200, Jiri Benc wrote:
>> As network adapters supporting PTP are becoming more common, machines with
>> many NICs suddenly have many PHCs, too. The current limit of eight /dev/ptp*
>> char devices (and thus, 8 network interfaces with PHC) is insufficient. Let
>> the ptp driver allocate the char devices dynamically.
>> 
>> Tested with 28 PHCs, removing and re-adding some of them.
>> 
>> Thanks to Ben Hutchings for advice leading to simpler and cleaner patch.
>> 
>> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

This patch looks great, applied, thanks everyone.
