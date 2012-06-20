From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] team: two RCU fixups
Date: Wed, 20 Jun 2012 14:27:36 -0700 (PDT)
Message-ID: <20120620.142736.553888022135735828.davem@davemloft.net>
References: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
	<20120620.140516.2004640533824596305.davem@davemloft.net>
	<1340227176.4604.1913.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681Ab2FTV1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:27:37 -0400
In-Reply-To: <1340227176.4604.1913.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 23:19:36 +0200

> On Wed, 2012-06-20 at 14:05 -0700, David Miller wrote:
>> From: Jiri Pirko <jpirko@redhat.com>
>> Date: Wed, 20 Jun 2012 17:31:59 +0200
>> 
>> > Jiri Pirko (2):
>> >   team: use rcu_access_pointer to access RCU pointer by writer
>> >   team: use RCU_INIT_POINTER for NULL assignment of RCU pointer
>> 
>> Applied, but this makes your subsequent patch not apply.
> 
> I reviewed them and spotted problems, and you applied them...
> 
> Then Jiri sent an update.

Sorry, I'll fix this up.
