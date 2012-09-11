From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
Date: Tue, 11 Sep 2012 16:39:19 +0800
Message-ID: <1347352759.30731.38.camel@cr0>
References: <1347281326-26890-2-git-send-email-amwang@redhat.com>
	 <20120910.163229.421777922179988802.davem@davemloft.net>
	 <1347326362.30731.9.camel@cr0>
	 <20120910.214245.368123682481775366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab2IKIjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 04:39:25 -0400
In-Reply-To: <20120910.214245.368123682481775366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 21:42 -0400, David Miller wrote:
> 
> Yes, I know this conflicts with cases like how we killed all of
> the netlink macros with embedded gotos.
> 
> But this patch made things worse and added code duplication.  Fix
> it without the code duplication side effect and it'll be fine.

Ok, will do.

Thanks, David!
