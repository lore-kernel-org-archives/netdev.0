From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/5] l2tp: fixes for l2tp_ip and l2tp_ip6 socket
 handling
Date: Wed, 30 Nov 2016 14:14:31 -0500 (EST)
Message-ID: <20161130.141431.499272222182312623.davem@davemloft.net>
References: <cover.1480419658.git.g.nault@alphalink.fr>
        <7de5b95e-b33a-fce4-cb59-4a4415e39697@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: g.nault@alphalink.fr, netdev@vger.kernel.org, celston@katalix.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39892 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753815AbcK3TOd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:14:33 -0500
In-Reply-To: <7de5b95e-b33a-fce4-cb59-4a4415e39697@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 29 Nov 2016 13:47:06 +0000

> On 29/11/16 12:09, Guillaume Nault wrote:
>> This series addresses problems found while working on commit 32c231164b76
>> ("l2tp: fix racy SOCK_ZAPPED flag check in l2tp_ip{,6}_bind()").
>>
>> The first three patches fix races in socket's connect, recv and bind
>> operations. The last two ones fix scenarios where l2tp fails to
>> correctly lookup its userspace sockets.
>>
>> Apart from the last patch, which is l2tp_ip6 specific, every patch
>> fixes the same problem in the L2TP IPv4 and IPv6 code.
>>
>> All problems fixed by this series exist since the creation of the
>> l2tp_ip and l2tp_ip6 modules.
>>
>> Changes since v1:
>>   * Patch #3: fix possible uninitialised use of 'ret' in l2tp_ip_bind().
 ...
> Looks good.
> 
> Acked-by: James Chapman <jchapman@katalix.com>

Series applied.
