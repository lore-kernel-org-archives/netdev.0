From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/7] bridge: per-vlan stats
Date: Thu, 28 Apr 2016 10:43:07 +0200
Message-ID: <5721CD1B.7000101@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37514 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbcD1InL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 04:43:11 -0400
Received: by mail-wm0-f53.google.com with SMTP id a17so52793273wme.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 01:43:11 -0700 (PDT)
In-Reply-To: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2016 06:18 PM, Nikolay Aleksandrov wrote:
> Hi,
> This set adds support for bridge per-vlan statistics.
> In order to be able to dump statistics we need a way to continue
> dumping after reaching maximum size, thus patches 01-03 extend the new
> stats API with a per-device extended link stats attribute and callback
> which can save its local state and continue where it left off afterwards.
> I considered using the already existing "fill_xstats" callback but it gets
> confusing since we need to separate the linkinfo dump from the new stats
> api dump and adding a flag/argument to do that just looks messy. I don't
> think the rtnl_link_ops size is an issue, so adding these seemed like the
> cleaner approach.
> 
> Patch 05 converts the pvid to a pointer so we can consolidate the vlan
> stats accounting paths later, also allows to simplify the pvid code.
> Patches 06 and 07 add the stats support and netlink dump support
> respectively.
> I've tested this set with both old and modified iproute2, kmemleak on and
> some traffic stress tests while adding/removing vlans and ports.
> 
> Thank you,
>  Nik
> 
> Note: Jamal I haven't forgotten about the per-port per-vlan stats, I've got
> a follow-up patch that adds it. You can easily see that the infrastructure
> for private port/vlan stats is in place after this set. Though the stats
> api will need some more changes to support that.
> 
> 
[snip]

Self-NAK
I'll post a v2 after a couple of days, I'd like to make some minor changes and also
address the feedback in the process.

Thanks,
 Nik
