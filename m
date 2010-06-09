From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH][RFC] Check sk_buff states
Date: Wed, 09 Jun 2010 09:14:06 +0200
Message-ID: <878w6o65kx.fsf@basil.nowhere.org>
References: <20100608003055.GA29405@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49199 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab0FIHOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 03:14:12 -0400
In-Reply-To: <20100608003055.GA29405@dvomlehn-lnx2.corp.sa.net> (David VomLehn's message of "Mon\, 7 Jun 2010 17\:30\:55 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David VomLehn <dvomlehn@cisco.com> writes:
>
> Some of the errors that can be detected are:
> o	Double-freeing an skb_buff

slab debugging should already catch that (although at higher cost)

I would say the big question is how many bugs such a new infrastructure
find. Did you find any?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
