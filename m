From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 1/6] sctp: add sctp_info dump api for
 sctp_diag
Date: Fri, 15 Apr 2016 17:28:58 -0400 (EDT)
Message-ID: <20160415.172858.253625178036493951.davem@davemloft.net>
References: <cover.1460618169.git.lucien.xin@gmail.com>
	<cover.1460618169.git.lucien.xin@gmail.com>
	<cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbcDOV3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 17:29:01 -0400
In-Reply-To: <cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 14 Apr 2016 15:35:30 +0800

> sctp_diag will dump some important details of sctp's assoc or ep, we use
> sctp_info to describe them,  sctp_get_sctp_info to get them, and export
> it to sctp_diag.ko.
> 
> v2->v3:
> - we will not use list_for_each_safe in sctp_get_sctp_info, cause
>   all the callers of it will use lock_sock.
> 
> - fix the holes in struct sctp_info with __reserved* field.
>   because sctp_diag is a new feature, and sctp_info is just for now,
>   it may be changed in the future.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Feedback was given here not to mix the changelog and the commit message.

And I want to explicitly state that I totally and _COMPLETELY_ disagree
with this.

It is absolutely essential information and belongs in the commit message.

Adding more information never hurts, so don't do this crap of putting
things that might be useful to know after the "---", ever.

Someone in the future might ask "why didn't he implement it like XXX"
and the changelog can tell him that originally that is what was done
and feedback was given to do it differently.

So Xin thanks for correctly putting the changelog inside of the commit
message, so that future developers can benefit from this knowledge.
