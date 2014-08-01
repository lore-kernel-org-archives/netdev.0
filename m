From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] inet: frags: rename last_in to flags,
 enum the definitions and add comments
Date: Thu, 31 Jul 2014 22:13:49 -0700 (PDT)
Message-ID: <20140731.221349.304058285592989214.davem@davemloft.net>
References: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
	<1406819499-11198-3-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	alex.aring@gmail.com, eric.dumazet@gmail.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbaHAFNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:13:50 -0400
In-Reply-To: <1406819499-11198-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 31 Jul 2014 17:11:37 +0200

> The last_in field has been used to store various flags different from
> first/last frag in so give it a more descriptive name: flags. Move
> the flags to an enum definion, swap FIRST_IN/LAST_IN to be in logical
> order and add comments explaining each flag, also add comments explaining
> the inet_frag_queue struct members. While at it align some function
> declarations.

When I hear things like "also" and "while at it", what I really hear is
"that should be done in a separate patch".

Please don't clump so many unrelated changes together, it makes the
patch harder to review than necessary, thanks.
