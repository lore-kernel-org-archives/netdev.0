From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netconsole: enable netconsole can make net_device
 refcnt incorrent
Date: Tue, 18 Oct 2011 23:55:39 -0400 (EDT)
Message-ID: <20111018.235539.636455324005288300.davem@davemloft.net>
References: <1318385291-15483-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20111012102344.0b718260@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab1JSDzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:55:47 -0400
In-Reply-To: <20111012102344.0b718260@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 12 Oct 2011 10:23:44 -0300

> On Wed, 12 Oct 2011 10:08:11 +0800
> Gao feng <gaofeng@cn.fujitsu.com> wrote:
> 
>> There is no check if netconsole is enabled current.
>> so when exec echo 1 > enabled;
>> the reference of net_device will increment always.
>> 
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  drivers/net/netconsole.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> Looks better, thanks!
> Acked-by: Flavio Leitner <fbl@redhat.com>

Applied, thanks everyone.
