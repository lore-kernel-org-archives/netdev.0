From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun: compare with 0 instead of total_len
Date: Tue, 13 Aug 2013 19:29:43 -0700 (PDT)
Message-ID: <20130813.192943.865924891130626725.davem@davemloft.net>
References: <732ec15a7682b3ab87858de0b19a0848f0ad8944.1376399185.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wpan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759125Ab3HNC3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 22:29:44 -0400
In-Reply-To: <732ec15a7682b3ab87858de0b19a0848f0ad8944.1376399185.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <wpan@redhat.com>
Date: Tue, 13 Aug 2013 21:46:56 +0800

> Since we set "len = total_len" in the beginning of tun_get_user(),
> so we should compare the new len with 0, instead of total_len,
> or the if statement always returns false.
> 
> Signed-off-by: Weiping Pan <wpan@redhat.com>

Definitely looks correct to me, applied, thanks.
