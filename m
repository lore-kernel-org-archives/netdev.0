From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] virtio-net: free bufs correctly on invalid packet
 length
Date: Fri, 06 Dec 2013 16:32:35 -0500 (EST)
Message-ID: <20131206.163235.687717622324552173.davem@davemloft.net>
References: <1386278045-23542-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, rusty@rustcorp.com.au,
	mst@redhat.com, jasowang@redhat.com, avagin@openvz.org,
	virtualization@lists.linux-foundation.org
To: mwdalton@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758521Ab3LFVch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:32:37 -0500
In-Reply-To: <1386278045-23542-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Dalton <mwdalton@google.com>
Date: Thu,  5 Dec 2013 13:14:05 -0800

> When a packet with invalid length arrives, ensure that the packet
> is freed correctly if mergeable packet buffers and big packets
> (GUEST_TSO4) are both enabled.
> 
> Signed-off-by: Michael Dalton <mwdalton@google.com>

Applied, is this needed for -stable?
