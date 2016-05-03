From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add new struct ipcm6_cookie
Date: Mon, 02 May 2016 22:39:45 -0400 (EDT)
Message-ID: <20160502.223945.1841569316439730448.davem@davemloft.net>
References: <1461976272-10738-1-git-send-email-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239AbcECCjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 22:39:48 -0400
In-Reply-To: <1461976272-10738-1-git-send-email-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 29 Apr 2016 17:31:12 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In the sendmsg function of UDP, raw, ICMP and l2tp sockets, we use local
> variables like hlimits, tclass, opt and dontfrag and pass them to corresponding
> functions like ip6_make_skb, ip6_append_data and xxx_push_pending_frames.
> This is not a good practice and makes it hard to add new parameters.
> This fix introduces a new struct ipcm6_cookie similar to ipcm_cookie in
> ipv4 and include the above mentioned variables. And we only pass the
> pointer to this structure to corresponding functions. This makes it easier
> to add new parameters in the future and makes the function cleaner.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>

Looks good, applied, thank you.
