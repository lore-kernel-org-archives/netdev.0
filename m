From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net/mlx4_en: Add accelerated RFS support
Date: Wed, 18 Jul 2012 14:34:56 -0700 (PDT)
Message-ID: <20120718.143456.1078493346727092667.davem@davemloft.net>
References: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
	<20120718.114158.2161516212050365274.davem@davemloft.net>
	<CAJZOPZL8842H9H7404qjugCPpdhijjUhxk0Kn6BfBONCbE-tNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, amirv@mellanox.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab2GRVfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:35:07 -0400
In-Reply-To: <CAJZOPZL8842H9H7404qjugCPpdhijjUhxk0Kn6BfBONCbE-tNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Thu, 19 Jul 2012 00:22:42 +0300

> On Wed, Jul 18, 2012 at 9:41 PM, David Miller <davem@davemloft.net> wrote:
> 
>> Please use CONFIG_RFS_ACCEL consistently to protect this feature
>> in your driver sources.
>>
>> Using CPU_RMAP in a few places is inconsistent, and not what other
>> drivers do.
> 
> We're indeed using CONFIG_RFS_ACCEL across the place, and only in two
> places which deal directly with rmap use CPU_RMAP. The latter is
> selected by RFS_ACCEL, but if you feel this is inconsistent, will
> change to use only one define.

That's basically what I said.
