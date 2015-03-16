From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next V1 1/3] net: Add max rate tx queue attribute
Date: Mon, 16 Mar 2015 13:01:18 -0700
Message-ID: <5507368E.6030107@gmail.com>
References: <1426150405-7904-1-git-send-email-ogerlitz@mellanox.com>	<1426150405-7904-2-git-send-email-ogerlitz@mellanox.com> <20150315.010727.1396856705582316764.davem@davemloft.net> <550537C2.3080107@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	amirv@mellanox.com, idos@mellanox.com, matanb@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33134 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbbCPUBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:01:53 -0400
Received: by pagr17 with SMTP id r17so74194718pag.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 13:01:52 -0700 (PDT)
In-Reply-To: <550537C2.3080107@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/03/15 00:41, Or Gerlitz wrote:
> On 3/15/2015 7:07 AM, David Miller wrote:
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>> This is more succinctly expressed as:
>>
>>     err = -EOPNOTSUPP;
>>     if (dev->netdev_ops->ndo_set_tx_maxrate) {
>>         err = dev->netdev_ops->ndo_set_tx_maxrate(dev, index, rate);
>>     if (!err) {
>>         queue->tx_maxrate = rate;
>>         return len;
>>     }
>>     return err;
>>
> 
> sure, I'll fix that.

Can you also include a patch which updates the sysfs documentation at
Documentation/ABI/testing/sysfs-class-net-queues? Thanks!
-- 
Florian
