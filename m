From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: don't permit unprivileged writes to global
 state via sysctls
Date: Sat, 22 Oct 2016 18:43:16 -0400 (EDT)
Message-ID: <20161022.184316.791487930434404648.davem@davemloft.net>
References: <20161020182224.GA10999@salvia>
        <20161020.143747.1033652491220298518.davem@davemloft.net>
        <20161022212342.GD3334@pc.thejh.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: jann@thejh.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756077AbcJVWnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 18:43:24 -0400
In-Reply-To: <20161022212342.GD3334@pc.thejh.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jann Horn <jann@thejh.net>
Date: Sat, 22 Oct 2016 23:23:42 +0200

> On Thu, Oct 20, 2016 at 02:37:47PM -0400, David Miller wrote:
>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> Date: Thu, 20 Oct 2016 20:22:24 +0200
>> 
>> > On Sat, Sep 24, 2016 at 12:21:04AM +0200, Jann Horn wrote:
>> >> This prevents the modification of nf_conntrack_max in unprivileged network
>> >> namespaces. For unprivileged network namespaces, ip_conntrack_max is kept
>> >> as a readonly sysctl in order to minimize potential compatibility issues.
>> >> 
>> >> This patch should apply cleanly to the net tree.
>> > 
>> > For the record: This patch looks good to me, but this legacy
>> > ip_conntrack sysctl code is now gone.
>> > 
>> > I don't know what is the procedure to get this to -stable branches now
>> > that this cannot be pushed upstream.
>> 
>> In the commit message for the -stable submission simply say "Not
>> applicable" in the upstream commit reference.  Like:
>> 
>> 	[ Upstream commit: Not applicable ]
>> 
>> or something like that.
> 
> Who should do that? Me, after getting a maintainer ack? Or the maintainer?

When the maintainer submits a patch to -stable, that's what they
add to the commit message.
