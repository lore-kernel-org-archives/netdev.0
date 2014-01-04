From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: unify the pcpu_tstats and br_cpu_netstats
Date: Fri, 03 Jan 2014 19:32:53 -0500 (EST)
Message-ID: <20140103.193253.2226162174184357030.davem@davemloft.net>
References: <1388653054-4341-1-git-send-email-roy.qing.li@gmail.com>
	<slrnlccgj7.3uh.xiyou.wangcong@linux-6brj.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271AbaADAcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:32:54 -0500
In-Reply-To: <slrnlccgj7.3uh.xiyou.wangcong@linux-6brj.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 3 Jan 2014 04:53:47 +0000 (UTC)

> On Thu, 02 Jan 2014 at 08:57 GMT, roy.qing.li@gmail.com <roy.qing.li@gmail.com> wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> They are same, so unify them as one, pcpu_tstats.
>> and move pcpu_tstat into netdevice.h
>>
> 
> tstats means Tunnel STATS, right? So, it has to be
> in if_tunnel.h.

They are being used in the bridging code now, did you read the
patch?

So not really limited to just tunnels, and therefore they really do
belong somewhere generic like netdevice.h

This also means that since they are now an encapsulation thing we
should rename them to pcpu_encap_stats or similar, thanks.
