From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Wed, 12 Apr 2017 21:54:31 -0400 (EDT)
Message-ID: <20170412.215431.1851482226330564808.davem@davemloft.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <20170412143037.5fd7a088@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755174AbdDMByf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 21:54:35 -0400
In-Reply-To: <20170412143037.5fd7a088@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 12 Apr 2017 14:30:37 -0700

> On Wed, 12 Apr 2017 14:54:15 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index b0aa089..071a58b 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1891,9 +1891,17 @@ struct net_device {
>>  	struct lock_class_key	*qdisc_tx_busylock;
>>  	struct lock_class_key	*qdisc_running_key;
>>  	bool			proto_down;
>> +	struct bpf_prog __rcu	*xdp_prog;
> 
> It would be good if all devices could reuse this for the xdp_prog pointer.
> It would allow for could be used for introspection utility functions in future.

We plan to do so.
