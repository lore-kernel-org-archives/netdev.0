From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sched: cls_flower: Correct matching on ICMPv6
 code
Date: Mon, 30 Jan 2017 16:42:41 -0500 (EST)
Message-ID: <20170130.164241.1548388357085490430.davem@davemloft.net>
References: <1485789542-6346-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dinan.gunawardena@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41762 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754481AbdA3Vnn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 16:43:43 -0500
In-Reply-To: <1485789542-6346-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon, 30 Jan 2017 16:19:02 +0100

> When matching on the ICMPv6 code ICMPV6_CODE rather than
> ICMPV4_CODE attributes should be used.
> 
> This corrects what appears to be a typo.
> 
> Sample usage:
> 
> tc qdisc add dev eth0 ingress
> tc filter add dev eth0 protocol ipv6 parent ffff: flower \
> 	indev eth0 ip_proto icmpv6 type 128 code 0 action drop
> 
> Without this change the code parameter above is effectively ignored.
> 
> Fixes: 7b684884fbfa ("net/sched: cls_flower: Support matching on ICMP type and code")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks a lot Simon.
