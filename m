From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] dctcp: update cwnd on congestion event
Date: Tue, 15 Nov 2016 22:02:40 -0500 (EST)
Message-ID: <20161115.220240.164646299093092679.davem@davemloft.net>
References: <1479138121-32294-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brakmo@fb.com, agshew@gmail.com,
        glenn.judd@morganstanley.com, daniel@iogearbox.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752578AbcKPDCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:02:42 -0500
In-Reply-To: <1479138121-32294-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 14 Nov 2016 16:42:01 +0100

> draft-ietf-tcpm-dctcp-02 says:
> 
> ... when the sender receives an indication of congestion
> (ECE), the sender SHOULD update cwnd as follows:
> 
>          cwnd = cwnd * (1 - DCTCP.Alpha / 2)
> 
> So, lets do this and reduce cwnd more smoothly (and faster), as per
> current congestion estimate.
> 
> Cc: Lawrence Brakmo <brakmo@fb.com>
> Cc: Andrew Shewmaker <agshew@gmail.com>
> Cc: Glenn Judd <glenn.judd@morganstanley.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
