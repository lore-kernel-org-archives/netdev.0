From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tunnels: Allow IPv6 UDP checksums to be correctly
 controlled.
Date: Thu, 21 Jan 2016 11:13:21 -0800 (PST)
Message-ID: <20160121.111321.1645988832633186651.davem@davemloft.net>
References: <1453335767-49234-1-git-send-email-jesse@kernel.org>
	<20160121155715.511dfc8e@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbcAUTNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 14:13:23 -0500
In-Reply-To: <20160121155715.511dfc8e@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 21 Jan 2016 15:57:15 +0100

> On Wed, 20 Jan 2016 16:22:47 -0800, Jesse Gross wrote:
>> When configuring checksums on UDP tunnels, the flags are different
>> for IPv4 vs. IPv6 (and reversed). However, when lightweight tunnels
>> are enabled the flags used are always the IPv4 versions, which are
>> ignored in the IPv6 code paths. This uses the correct IPv6 flags, so
>> checksums can be controlled appropriately.
>> 
>> Fixes: a725e514 ("vxlan: metadata based tunneling for IPv6")
>> Fixes: abe492b4 ("geneve: UDP checksum configuration via netlink")
>> Signed-off-by: Jesse Gross <jesse@kernel.org>
> 
> Indeed. Thanks for spotting this.
> 
> Acked-by: Jiri Benc <jbenc@redhat.com>

Applied, and queued up for -stable.

Thanks.
