From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/6] hash: Introduce ptr_hash_mix routine
Date: Tue, 07 Aug 2012 12:30:05 +0200
Message-ID: <1344335405.26674.91.camel@edumazet-glaptop>
References: <501FD0F2.4040609@parallels.com>
	 <501FD11B.6000006@parallels.com>
	 <20120806.134459.954167716448843820.davem@davemloft.net>
	 <5020DBCD.7040806@parallels.com>
	 <1344331716.26674.89.camel@edumazet-glaptop>
	 <5020E610.1040808@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35160 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab2HGKaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 06:30:11 -0400
Received: by bkwj10 with SMTP id j10so1380135bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 03:30:10 -0700 (PDT)
In-Reply-To: <5020E610.1040808@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 13:55 +0400, Pavel Emelyanov wrote:

> OK. I was under impression, that hash_ptr was balanced from the fast/effective
> perspective, but I can't argue with you in that area :) So, please, consider
> the below patch instead of #1 and #2 (the rest ones remain unchanged).
> 
> Thanks,
> Pavel
> 
> 
> From: Pavel Emelyanov <xemul@parallels.com>
> Subject: [PATCH 1/5] net: Dont use ifindices in hash fns
> 
> Eric noticed, that when there will be devices with equal indices, some
> hash functions that use them will become less effective as they could.
> Fix this in advance by mixing the net_device address into the hash value
> instead of the device index.
> 
> This is true for arp and ndisc hash fns. The netlabel, can and llc ones
> are also ifindex-based, but that three are init_net-only, thus will not
> be affected.
> 
> Many thanks to David and Eric for the hash32_ptr implementation!
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  include/linux/hash.h |   10 ++++++++++
>  include/net/arp.h    |    3 ++-
>  include/net/ndisc.h  |    3 ++-
>  3 files changed, 14 insertions(+), 2 deletions(-)

Signed-off-by: Eric Dumazet <edumazet@google.com>

You should resend other patches, since they are no more on
http://patchwork.ozlabs.org/project/netdev/list/
