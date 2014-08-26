From: David Miller <davem@davemloft.net>
Subject: Re: linux/if_bridge.h no longer self contained (again)
Date: Mon, 25 Aug 2014 18:18:04 -0700 (PDT)
Message-ID: <20140825.181804.860202880963258005.davem@davemloft.net>
References: <CAGVrzcamm6bgTc_-1OZGD0L4DqQd5RfoVYftZic3MDvD8YMjxA@mail.gmail.com>
	<CAM_iQpV6EvvoYE17oi2XN0cbBkssQv0j=VXVR1-uCtMoJrSHwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	gregory.0xf0@gmail.com, carlos@redhat.com, eblake@redhat.com,
	galak@codeaurora.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159AbaHZBSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 21:18:06 -0400
In-Reply-To: <CAM_iQpV6EvvoYE17oi2XN0cbBkssQv0j=VXVR1-uCtMoJrSHwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 30 Jul 2014 16:20:07 -0700

> On Wed, Jul 30, 2014 at 3:05 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>
>> What would be the recommended ways to move forward?
>>
>> Should we keep a local change that includes netinet/in6.h and just
>> hope it does not cause any re-definitions?
>>
> 
> I think we should just #include <linux/in6.h> since the redefinition error
> was already fixed.

Someone please submit a patch to do so, and please include all of the context
such as the commits references in Florian's initial email of this thread.

Thanks.
