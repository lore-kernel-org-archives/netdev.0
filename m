From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net] bonding: fix accounting of active ports in 3ad
Date: Fri, 19 May 2017 18:15:57 -0400
Message-ID: <95c9a6b9-ac60-caa1-416d-c74e1aea08f4@redhat.com>
References: <20170517151144.57865-1-jarod@redhat.com>
 <20170519.171417.473208349438307952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57202 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754862AbdESWP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 18:15:58 -0400
In-Reply-To: <20170519.171417.473208349438307952.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-19 5:14 PM, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Wed, 17 May 2017 11:11:44 -0400
> 
>> As of 7bb11dc9f59d and 0622cab0341c, bond slaves in a 3ad bond are not
>> removed from the aggregator when they are down, and the active slave count
>> is NOT equal to number of ports in the aggregator, but rather the number
>> of ports in the aggregator that are still enabled.
>   ...
>> Remedy it by using the same logic introduced in
>> 7bb11dc9f59d in __bond_3ad_get_active_agg_info(), so sysfs, procfs and
>    ^^^^^^^^^^^^
>> netlink all report the number of active ports.
> 
> I think you mean to reference commit 0622cab0341c here not 7bb11dc9f59d.

D'oh, yes, you are entirely correct. Should I submit a v2 with that 
correction?

-- 
Jarod Wilson
jarod@redhat.com
