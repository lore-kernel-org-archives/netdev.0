From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests: psock_tpacket: fix status check
Date: Mon, 29 Apr 2013 12:27:07 -0400 (EDT)
Message-ID: <20130429.122707.744055587123930264.davem@davemloft.net>
References: <1366880880-3207-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758037Ab3D2Q1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 12:27:10 -0400
In-Reply-To: <1366880880-3207-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 25 Apr 2013 11:08:00 +0200

> Testing like this for TP_STATUS_AVAILABLE clearly is a stupid bug
> since it always returns true. Fix this by only checking for flags
> where the kernel owns the packet and negate this result, since we
> also could run into the non-zero status TP_STATUS_WRONG_FORMAT
> and need to reclaim frames.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
