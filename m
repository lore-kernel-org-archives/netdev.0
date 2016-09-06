From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: release dst in ping_v6_sendmsg
Date: Tue, 06 Sep 2016 12:56:05 -0700 (PDT)
Message-ID: <20160906.125605.2276804616901457581.davem@davemloft.net>
References: <20160902183950.p3iv25jnuwmq74sg@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52874 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932133AbcIFT4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 15:56:06 -0400
In-Reply-To: <20160902183950.p3iv25jnuwmq74sg@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Fri, 2 Sep 2016 14:39:50 -0400

> Neither the failure or success paths of ping_v6_sendmsg release
> the dst it acquires.  This leads to a flood of warnings from
> "net/core/dst.c:288 dst_release" on older kernels that
> don't have 8bf4ada2e21378816b28205427ee6b0e1ca4c5f1 backported.
> 
> That patch optimistically hoped this had been fixed post 3.10, but
> it seems at least one case wasn't, where I've seen this triggered
> a lot from machines doing unprivileged icmp sockets.
> 
> Cc: Martin Lau <kafai@fb.com>
> Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

Applied and queued up for -stable, thanks Dave.
