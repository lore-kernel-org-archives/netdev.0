From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: check raw payload size correctly in ioctl
Date: Wed, 26 Apr 2017 15:00:04 -0400 (EDT)
Message-ID: <20170426.150004.494655279490216482.davem@davemloft.net>
References: <1493167407-27969-1-git-send-email-jbainbri@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org
To: jbainbri@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965655AbdDZTAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 15:00:06 -0400
In-Reply-To: <1493167407-27969-1-git-send-email-jbainbri@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamie Bainbridge <jbainbri@redhat.com>
Date: Wed, 26 Apr 2017 10:43:27 +1000

> In situations where an skb is paged, the transport header pointer and
> tail pointer can be the same because the skb contents are in frags.
> 
> This results in ioctl(SIOCINQ/FIONREAD) incorrectly returning a
> length of 0 when the length to receive is actually greater than zero.
> 
> skb->len is already correctly set in ip6_input_finish() with
> pskb_pull(), so use skb->len as it always returns the correct result
> for both linear and paged data.
> 
> Signed-off-by: Jamie Bainbridge <jbainbri@redhat.com>

Applied and queued up for -stable, thanks.
