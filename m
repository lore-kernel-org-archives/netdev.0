From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
Date: Mon, 07 Oct 2013 15:36:22 -0400 (EDT)
Message-ID: <20131007.153622.1392772445100851507.davem@davemloft.net>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	xixiong@amazon.com, msw@amazon.com, annie.li@oracle.com,
	wei.liu2@citrix.com, Ian.Campbell@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755570Ab3JGTgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:36:25 -0400
In-Reply-To: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Fri, 4 Oct 2013 17:26:23 +0100

> Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an error into
> xenvif_count_skb_slots() for skbs with a linear area spanning a page
> boundary. The alignment of skb->data needs to be taken into account, not
> just the head length. This patch fixes the issue by dry-running the code
> from xenvif_gop_skb() (and adjusting the comment above the function to note
> that).
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

There seems to be a lot of back and forth about what is the most
desirable way forward wrt. this commit and another similar one.

Please advise.
