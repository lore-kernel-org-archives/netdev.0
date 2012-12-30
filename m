From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: return -EINVAL if BPF_S_ANC*
 operation is not supported
Date: Sun, 30 Dec 2012 02:30:58 -0800 (PST)
Message-ID: <20121230.023058.1273764783843598991.davem@davemloft.net>
References: <1356727817-10649-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ani@aristanetworks.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab2L3KbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 05:31:02 -0500
In-Reply-To: <1356727817-10649-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 28 Dec 2012 21:50:17 +0100

> Currently, we return -EINVAL for malformed or wrong BPF filters.
> However, this is not done for BPF_S_ANC* operations, which makes it
> more difficult to detect if it's actually supported or not by the
> BPF machine. Therefore, we should also return -EINVAL if K is within
> the SKF_AD_OFF universe and the ancillary operation did not match.
 ...
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Ani Sinha <ani@aristanetworks.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
