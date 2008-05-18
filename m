From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH updated] net: add ability to clear per-interface network
 statistics via procfs
Date: Sun, 18 May 2008 03:43:14 +0200
Message-ID: <482F89B2.6060108@trash.net>
References: <482DA5B6.1020606@sngx.net> <482DB46A.8020103@cosmosbay.com> <482EF192.4070707@sngx.net> <482F5113.5090703@cosmosbay.com> <482F610D.2080108@sngx.net> <20080518003104.GK28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Cammarata <jimi@sngx.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55842 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624AbYERBo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 21:44:27 -0400
In-Reply-To: <20080518003104.GK28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
>> +                        dev = dev_get_by_name(net,devname);
>> +                        if (dev) {
>> +                                if (dev->get_stats) {
>> +                                        struct net_device_stats *stats =
>> +                                               dev->get_stats(dev);
>> +                                        memset(stats,0,
>> +                                               sizeof(struct 
>> net_device_stats));

This doesn't work for devices that generate the stats (for
example by reading them from the hardware) in ->get_stats().

