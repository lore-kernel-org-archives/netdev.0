From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: fix mlx4_en_set_rxfh()
Date: Sun, 23 Nov 2014 09:05:20 -0800
Message-ID: <1416762320.17888.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
	 <1416692961.7215.31.camel@decadent.org.uk>
	 <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416705859.17888.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <547210EF.9030800@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:57924 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbaKWRFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 12:05:23 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so7738305iec.1
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2014 09:05:22 -0800 (PST)
In-Reply-To: <547210EF.9030800@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-23 at 18:53 +0200, Amir Vadai wrote:
> >  	 */
> >  	for (i = 0; i < priv->rx_ring_num; i++) {
> > +		if (!ring_index)
> > +			continue;
> 
> Why didn't you put the whole loop under the 'if'?

To avoid adding one indentation on the block, and ease this code review.

This is hardly fast path, and compiler does the optim for us anyway.
