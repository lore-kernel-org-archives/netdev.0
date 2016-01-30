From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/4] net/core: relax BUILD_BUG_ON in
 netdev_stats_to_stats64
Date: Sat, 30 Jan 2016 15:26:35 -0800 (PST)
Message-ID: <20160130.152635.1510710440132684620.davem@davemloft.net>
References: <1454178872.7627.136.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160130203900.GQ59058@redhat.com>
	<20160130205305.GR59058@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757106AbcA3X0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 18:26:40 -0500
In-Reply-To: <20160130205305.GR59058@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>
Date: Sat, 30 Jan 2016 15:53:05 -0500

> On Sat, Jan 30, 2016 at 03:39:01PM -0500, Jarod Wilson wrote:
>> Ew, no, it won't work correctly on 32-bit. The for loop is going to copy
>> data into dst from beyond the end of netdev_stats, and the range looks
>> like it won't be right either, only half of the added stats64 space will
>> get zeroed out. Okay, I'll fix that up correctly.
> 
> Completely untested as of yet, but I think something like the following
> looks correct. I'll give it a spin as soon as I can.

Jarod, please respin your entire series as a v3 once you sort this out.

Thanks.
