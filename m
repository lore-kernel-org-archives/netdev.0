From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: rename CONFIG_NET_LL_RX_POLL to
 CONFIG_NET_RX_BUSY_POLL
Date: Wed, 31 Jul 2013 17:01:03 -0700 (PDT)
Message-ID: <20130731.170103.1728448549547059368.davem@davemloft.net>
References: <1375177125-7209-1-git-send-email-amwang@redhat.com>
	<51F9128F.6030700@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: eliezer.tamir@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab3HAABE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:01:04 -0400
In-Reply-To: <51F9128F.6030700@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Wed, 31 Jul 2013 16:35:11 +0300

> On 30/07/2013 12:38, Cong Wang wrote:
>> From: Cong Wang <amwang@redhat.com>
>> 
>> Eliezer renames several *ll_poll to *busy_poll, but forgets
>> CONFIG_NET_LL_RX_POLL, so in case of confusion, rename it too.
>> 
>> Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Looks OK to me, but I'm not able to test it since I'm away on vacation.
> If you can test it with the usual config options and allnoconfig, then I
> have no objections to this patch.
> 
> If you want me to test it, that can only happen early next week.

Cong, you missed Documentation/sysctl/net.txt, please fix that up and
respin this patch.

Thanks.
