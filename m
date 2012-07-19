From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv4: use seqlock for nh_exceptions
Date: Thu, 19 Jul 2012 10:30:32 -0700 (PDT)
Message-ID: <20120719.103032.2091570066288728329.davem@davemloft.net>
References: <1342642535-2545-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab2GSRad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:30:33 -0400
In-Reply-To: <1342642535-2545-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 18 Jul 2012 23:15:35 +0300

> 	Use global seqlock for the nh_exceptions. Call
> fnhe_oldest with the right hash chain. Correct the diff
> value for dst_set_expires.
> 
> v2: after suggestions from Eric Dumazet:
> * get rid of spin lock fnhe_lock, rearrange update_or_create_fnhe
> * continue daddr search in rt_bind_exception
> 
> v3:
> * remove the daddr check before seqlock in rt_bind_exception
> * restart lookup in rt_bind_exception on detected seqlock change,
> as suggested by David Miller
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks a lot Julian.
