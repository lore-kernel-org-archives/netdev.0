From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tap: double-free in error path in tap_open()
Date: Thu, 26 Oct 2017 17:58:12 +0900 (KST)
Message-ID: <20171026.175812.1985944633273201892.davem@davemloft.net>
References: <1508916184-17473-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdJZI6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:58:16 -0400
In-Reply-To: <1508916184-17473-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Wed, 25 Oct 2017 00:23:04 -0700

> Double free of skb_array in tap module is causing kernel panic. When
> tap_set_queue() fails we free skb_array right away by calling
> skb_array_cleanup(). However, later on skb_array_cleanup() is called
> again by tap_sock_destruct through sock_put(). This patch fixes that
> issue.
> 
> Fixes: 362899b8725b35e3 (macvtap: switch to use skb array)
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---
> v1 -> v2:
>   - took care of an another issue in failure path of skb_array_init

Applied and queued up for -stable, thanks.
