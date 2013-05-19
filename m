From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next v2] ipv6: add support of peer address
Date: Sun, 19 May 2013 15:10:01 -0700 (PDT)
Message-ID: <20130519.151001.237409874641272058.davem@davemloft.net>
References: <1367313464-4338-1-git-send-email-nicolas.dichtel@6wind.com>
	<1368779520-4895-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215Ab3ESWKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 18:10:02 -0400
In-Reply-To: <1368779520-4895-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 17 May 2013 10:32:00 +0200

> This patch adds the support of peer address for IPv6. For example, it is
> possible to specify the remote end of a 6inY tunnel.
> This was already possible in IPv4:
>  ip addr add ip1 peer ip2 dev dev1
> 
> The peer address is specified with IFA_ADDRESS and the local address with
> IFA_LOCAL (like explained in include/uapi/linux/if_addr.h).
> Note that the API is not changed, because before this patch, it was not
> possible to specify two different addresses in IFA_LOCAL and IFA_REMOTE.
> There is a small change for the dump: if the peer is different from ::,
> IFA_ADDRESS will contain the peer address instead of the local address.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks Nicolas.
