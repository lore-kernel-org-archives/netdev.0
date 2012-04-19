From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] bonding: start slaves with link down for
 ARP monitor
Date: Thu, 19 Apr 2012 15:25:38 -0400 (EDT)
Message-ID: <20120419.152538.430981034620444725.davem@davemloft.net>
References: <20120417121135.5F9A740290@alaris.suse.cz>
	<20120418161912.1c0e2f4e@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab2DST0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 15:26:21 -0400
In-Reply-To: <20120418161912.1c0e2f4e@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 18 Apr 2012 16:19:12 -0300

> On Tue, 17 Apr 2012 14:02:06 +0200
> Michal Kubecek <mkubecek@suse.cz> wrote:
> 
>> Initialize slave device link state as down if ARP monitor is
>> active and net_carrier_ok() returns zero. Also shift initial
>> value of its last_arp_tx so that it doesn't immediately cause
>> fake detection of "up" state.
>> 
>> When ARP monitoring is used, initializing the slave device with
>> up link state can cause ARP monitor to detect link failure
>> before the device is really up (with igb driver, this can take
>> more than two seconds).
>> 
>> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied, thanks everyone.
