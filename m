From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: fix secpath leak
Date: Fri, 01 Sep 2017 10:30:22 -0700 (PDT)
Message-ID: <20170901.103022.450258953816266474.davem@davemloft.net>
References: <5bd7a6e643340d833718722c0508474c6c3a0a3a.1504260470.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yossiku@mellanox.com, paul@paul-moore.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752236AbdIARaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:30:23 -0400
In-Reply-To: <5bd7a6e643340d833718722c0508474c6c3a0a3a.1504260470.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri,  1 Sep 2017 14:42:30 +0200

> From: Yossi Kuperman <yossiku@mellanox.com>
> 
> After commit dce4551cb2ad ("udp: preserve head state for IP_CMSG_PASSSEC")
> we preserve the secpath for the whole skb lifecycle, but we also
> end up leaking a reference to it.
> 
> We must clear the head state on skb reception, if secpath is
> present.
> 
> Fixes: dce4551cb2ad ("udp: preserve head state for IP_CMSG_PASSSEC")
> Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
