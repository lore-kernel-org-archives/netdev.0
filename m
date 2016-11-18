From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: fix get_net_ns_by_fd(int pid) typo
Date: Fri, 18 Nov 2016 14:02:14 -0500 (EST)
Message-ID: <20161118.140214.602354945693248622.davem@davemloft.net>
References: <1479462106-28529-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752301AbcKRTCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 14:02:15 -0500
In-Reply-To: <1479462106-28529-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Fri, 18 Nov 2016 09:41:46 +0000

> The argument to get_net_ns_by_fd() is a /proc/$PID/ns/net file
> descriptor not a pid.  Fix the typo.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>

Applied.
