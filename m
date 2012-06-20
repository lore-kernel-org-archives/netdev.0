From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: do RCU update path fixups
Date: Wed, 20 Jun 2012 14:05:01 -0700 (PDT)
Message-ID: <20120620.140501.1474627180521558377.davem@davemloft.net>
References: <1340217579-1478-1-git-send-email-jpirko@redhat.com>
	<1340219643.4604.1641.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225Ab2FTVFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:05:02 -0400
In-Reply-To: <1340219643.4604.1641.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 21:14:03 +0200

> On Wed, 2012-06-20 at 20:39 +0200, Jiri Pirko wrote:
>> Use rcu_access_pointer and rcu_dereference_protected
>> to access RCU pointer by updater.
>> Use RCU_INIT_POINTER for NULL assignment of RCU pointer.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  drivers/net/team/team_mode_activebackup.c |    8 ++++++--
>>  drivers/net/team/team_mode_loadbalance.c  |   14 ++++++++++----
>>  2 files changed, 16 insertions(+), 6 deletions(-)
> 
> Seems good to me, thanks.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

This patch doesn't apply after the 2 patch set you sent right
before this one.
