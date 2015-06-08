From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] tcp: Force updating pcount after skb_pull()
 during mtu probing
Date: Mon, 08 Jun 2015 11:11:13 -0700
Message-ID: <1433787073.29864.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433551592-3596877-1-git-send-email-kafai@fb.com>
	 <1433553093.1895.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150608175833.GB390474@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Grant Zhang <gzhang@fastly.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37003 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbbFHSLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 14:11:16 -0400
Received: by igbsb11 with SMTP id sb11so63231008igb.0
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 11:11:16 -0700 (PDT)
In-Reply-To: <20150608175833.GB390474@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-08 at 10:58 -0700, Martin KaFai Lau wrote:

> It seems the invariant does not hold at this point also.
> Should the invariant fix be something for net-next? or Would you like
> to post a patch for it?

This patch definitely can target net-next, it is not a new regression.

Once fully tested, we can ask David to submit a stable version later.

Yes, I can provide a v3, probably at the end of today.
