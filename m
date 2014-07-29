From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Tue, 29 Jul 2014 16:46:32 -0700 (PDT)
Message-ID: <20140729.164632.2258407062406773850.davem@davemloft.net>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
	<877g2y9ulb.fsf@tassilo.jf.intel.com>
	<20140728122609.GB32337@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, amirv@mellanox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: vgoyal@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaG2Xqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 19:46:34 -0400
In-Reply-To: <20140728122609.GB32337@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivek Goyal <vgoyal@redhat.com>
Date: Mon, 28 Jul 2014 08:26:09 -0400

> On Sun, Jul 27, 2014 at 05:48:32PM -0700, Andi Kleen wrote:
>> Amir Vadai <amirv@mellanox.com> writes:
>> 
>> > Hi,
>> >
>> > I'm sending this patchset to net-next because it touches a commit [1] that was
>> > applied lately to net-next.
>> 
>> It would be better to have a generic function for "run with small
>> memory", that can be also triggered in other ways, e.g. a sysctl or
>> a boot opion, with kdump just another user.
>> 
>> There are low memory cases which are not kdump.
> 
> I am fine with a boot option to suggest low memory profile and kdump
> scripts can be modified to automatically append that command line option
> to second kernel.

I'm therefore going to assume that this patch series will be updated when the
new facility is added.
