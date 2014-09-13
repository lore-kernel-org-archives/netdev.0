From: David Miller <davem@davemloft.net>
Subject: Re: What is "Awaiting Upstream" ?
Date: Sat, 13 Sep 2014 15:33:19 -0400 (EDT)
Message-ID: <20140913.153319.2070458565920303316.davem@davemloft.net>
References: <CAMw6YJJDvyq4zdjvpOYF=MnT++iJteN2-sd_OXMxEvghREQFWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbaIMTdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 15:33:21 -0400
In-Reply-To: <CAMw6YJJDvyq4zdjvpOYF=MnT++iJteN2-sd_OXMxEvghREQFWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>
Date: Sat, 13 Sep 2014 21:27:57 +0300

> Sorry for the noise, I tried to google but did not find the answer:
> 
>    Could someone explain what does it mean "Awaiting Upstream" status
>    for the sent patch in the patchwork system ?

It means that the patch isn't going directly into my tree, and should
be picked up by the maintainer of the subsystem that handles such
cases.

This is what happens for nearly all wireless, netfilter, and IPSEC
changes.

Because all of those subsystems have their own top-level maintainers
from which I pull from.
