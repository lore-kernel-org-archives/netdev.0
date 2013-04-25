From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] packet: reorder a member in
 packet_ring_buffer
Date: Thu, 25 Apr 2013 01:29:57 -0400 (EDT)
Message-ID: <20130425.012957.1907154593971601142.davem@davemloft.net>
References: <1366387949-9161-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3DYF37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:29:59 -0400
In-Reply-To: <1366387949-9161-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 19 Apr 2013 18:12:28 +0200

> There's a 4 byte hole in packet_ring_buffer structure before
> prb_bdqc, that can be filled with 'pending' member, thus we can
> reduce the overall structure size from 224 bytes to 216 bytes.
> This also has the side-effect, that in struct packet_sock 2*4 byte
> holes after the embedded packet_ring_buffer members are removed,
> and overall, packet_sock can be reduced by 1 cacheline:
> 
> Before: size: 1344, cachelines: 21, members: 24
> After:  size: 1280, cachelines: 20, members: 24
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
