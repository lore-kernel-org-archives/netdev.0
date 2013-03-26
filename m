From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: fix ip_summed checksum reporting on rx
Date: Tue, 26 Mar 2013 12:21:19 -0400 (EDT)
Message-ID: <20130326.122119.991326464629967782.davem@davemloft.net>
References: <1364286381-10031-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965650Ab3CZQVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:21:21 -0400
In-Reply-To: <1364286381-10031-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 26 Mar 2013 09:26:21 +0100

> skb->ip_summed should be CHECKSUM_UNNECESSARY when the driver reports that
> checksums were correct and CHECKSUM_NONE in any other case. They're
> currently placed vice versa, which breaks the forwarding scenario. Fix it
> by placing them as described above.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied and queued up for -stable, thanks.
