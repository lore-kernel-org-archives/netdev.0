From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] sock: lockdep tightening
Date: Thu, 07 Apr 2016 16:44:33 -0400 (EDT)
Message-ID: <20160407.164433.1018956939607816921.davem@davemloft.net>
References: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278AbcDGUok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 16:44:40 -0400
In-Reply-To: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue,  5 Apr 2016 17:10:13 +0200

> First patch is from Eric Dumazet and improves lockdep accuracy for
> socket locks. After that, second patch introduces lockdep_sock_is_held
> and uses it. Final patch reverts and reworks the lockdep fix from Daniel
> in the filter code, as we now have tighter lockdep support.

Series applied, thanks Hannes.
