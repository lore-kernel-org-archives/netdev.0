From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH V1 net-next] IB/ipoib: Fix ndo_get_iflink
Date: Mon, 20 Apr 2015 12:21:57 +0300
Message-ID: <CAJ3xEMgRDT+h7D3smju2VFTovA4J38ZnK3R4PD4+Xisbg40Tyg@mail.gmail.com>
References: <1429191274-11600-1-git-send-email-erezsh@mellanox.com>
	<20150417.152133.1818018053733533978.davem@davemloft.net>
	<5534B5E2.6060804@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>,
	Roland Dreier <roland@kernel.org>,
	David Miller <davem@davemloft.net>,
	Erez Shitrit <erezsh@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Honggang Li <honli@redhat.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:35347 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226AbbDTJV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 05:21:58 -0400
In-Reply-To: <5534B5E2.6060804@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2015 at 11:16 AM, Haggai Eran <haggaie@mellanox.com> wrote:
> On 17/04/2015 22:21, David Miller wrote:
>> From: Erez Shitrit <erezsh@mellanox.com>
>> Date: Thu, 16 Apr 2015 16:34:34 +0300
>>
>>> Currently, iflink of the parent interface was always accessed, even
>>> when interface didn't have a parent and hence we crashed there.
>>>
>>> Handle the interface types properly: for a child interface, return
>>> the ifindex of the parent, for parent interface, return its ifindex.
>>>
>>> For child devices, make sure to set the parent pointer prior to
>>> invoking register_netdevice(), this allows the new ndo to be called
>>> by the stack immediately after the child device is registered.
>>>
>>> Fixes: 5aa7add8f14b ('infiniband/ipoib: implement ndo_get_iflink')
>>> Reported-by: Honggang Li <honli@redhat.com>
>>> Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
>>> Signed-off-by: Honggang Li <honli@redhat.com>
>>
>> Applied, thanks.
>
> Doug, Roland,
> You might want to include this patch in your for-next / for-4.1 trees,
> or merge net-next again. Currently they contain the issue it fixes, and
> it can prevent some systems with IPoIB from booting.

Haggai,


It's upstream by now, pull Linus tree.

Or.
