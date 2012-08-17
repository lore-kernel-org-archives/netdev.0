From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH net] net: Remove unused variables in rt_cache_stat
Date: Fri, 17 Aug 2012 23:59:15 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208172358220.3927@frira.zrqbmnf.qr>
References: <1343684750-2987-1-git-send-email-subramanian.vijay@gmail.com> <20120730.145220.328852279916272895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([5.9.24.206]:56048 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755802Ab2HQV7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 17:59:16 -0400
In-Reply-To: <20120730.145220.328852279916272895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 2012-07-30 23:52, David Miller wrote:

>From: Vijay Subramanian <subramanian.vijay@gmail.com>
>Date: Mon, 30 Jul 2012 14:45:50 -0700
>
>> With the removal of the routing cache, some variables in rt_cache_stat are no
>> longer used. Remove them from rt_cache_stat and do not print them out in
>> /proc/net/stat/rt_cache.
>> 
>> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
>> ---
>> checkpatch complains that the seq_printf line is over 80 chars which was already
>> the case. I left it as is to aid in grepping the sources. 
>
>You cannot make this change, these fields are exported via procfs and
>therefore you will break any application that is parsing the existing
>layout.

Then the fields should just be printed with a static zero, like it's
done in procfs.
