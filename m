From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 14 Aug 2012 14:07:36 -0700 (PDT)
Message-ID: <20120814.140736.812697309119422215.davem@davemloft.net>
References: <1344358266-5450-1-git-send-email-timur@freescale.com>
	<CAOZdJXUB7jLZ_p3TmOs+p=jQM4Xs0a=HUdFia5N46M--LYyXJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.daney@cavium.com, netdev@vger.kernel.org
To: B04825@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757537Ab2HNVHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:07:37 -0400
In-Reply-To: <CAOZdJXUB7jLZ_p3TmOs+p=jQM4Xs0a=HUdFia5N46M--LYyXJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tabi Timur-B04825 <B04825@freescale.com>
Date: Tue, 14 Aug 2012 19:19:58 +0000

> On Tue, Aug 7, 2012 at 11:51 AM, Timur Tabi <timur@freescale.com> wrote:
>> The mdio-mux driver scans all child mdio nodes, without regard to whether
>> the node is actually used.  Some device trees include all possible
>> mdio-mux nodes and rely on the boot loader to disable those that are not
>> present, based on some run-time configuration.  Those nodes need to be
>> skipped.
>>
>> Signed-off-by: Timur Tabi <timur@freescale.com>
>> ---
> 
> Any chance this patch can get into 3.6?  I don't know if it qualifies
> as a fix or not, but getting it into 3.6 would make it easier for me
> to apply other patches to the powerpc tree.
> 

I want you to implement it the way David Daney said to do so.

And you never need to ask me questions like this, I clearly mark the
state of your patch:

http://patchwork.ozlabs.org/patch/175750/

So that you can just monitor it instead of wasting my time asking what
is happening to your patch.

Time of mine you consume forcing me to reply to you in situations like
this, which you could handle on your own, is time that I can't spend
reviewing patches from oher people that really are ready to go into
the tree.
