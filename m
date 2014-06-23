From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: Re: Stable request for 5882a07c72093d
Date: Mon, 23 Jun 2014 15:37:18 -0700
Message-ID: <CACviX4FkJ+kCqHAZ9O7pC1N_DpAhYfwySwp-Cw0AgAJcJH_9Dg@mail.gmail.com>
References: <1403539016-15519-1-git-send-email-chiluk@canonical.com>
	<1403540316.27425.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<53A8656F.4070407@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, davem <davem@davemloft.net>
To: chiluk@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f169.google.com ([209.85.128.169]:63261 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaFWWhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 18:37:19 -0400
Received: by mail-ve0-f169.google.com with SMTP id pa12so6853621veb.28
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 15:37:19 -0700 (PDT)
In-Reply-To: <53A8656F.4070407@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2014 at 10:35 AM, Dave Chiluk <chiluk@canonical.com> wrote:
> On 06/23/2014 11:18 AM, Eric Dumazet wrote:
>> On Mon, 2014-06-23 at 10:56 -0500, Dave Chiluk wrote:
>>> Commit 5882a07c72093dc3a18e2d2b129fb200686bb6ee remedies a BUG_ON in
>>> skb_segment.  This is hit reliably in clouds that are using openvswitch for
>>> network capabilities (which is the default network used by Openstack) on
>>> machines that have gso offload capabilities.
>>>
>>> This has already been reported multiple times to Canonical in numerous
>>> openstack clouds.  The fix has been integrated and tested in those clouds, and
>>> has been show to resolve their issues.
>>>
>>> Please include this patch for stable release.
>>>
>>> Thank you,
>>> Dave Chiluk
>>>
>>> The patch follows for convenience.
>>> --
>>
>> Both original commit and your request lack the bug origin.
>>
>> I wish bug submissions are more explicit in this regard, using
>>
>> Fixes: sha1-12digits ("title")
>>
>> It would save a lot of time for stable teams, and ease future bug
>> hunting as well.
>>
>>
> According to the initial thread, Wei-Chun determined it originated with
> 19acc327258a.  It has existed since 3.10-rc1.
>
> Fixes: 19acc327258a ("gso: Handle Trans-Ether-Bridging protocol in
> skb_network_protocol()")
>

Sorry I didn't include the bug origin in the original patch.

The issue was introduced by the combination of these two commits -
ec5f06156423 ("net: Kill link between CSUM and SG features.)
19acc327258a ("gso: Handle Trans-Ether-Bridging protocol in
skb_network_protocol()")

Thanks,
Weichun
