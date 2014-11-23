From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] mlx4: fix mlx4_en_set_rxfh()
Date: Sun, 23 Nov 2014 12:56:31 -0800
Message-ID: <1416776191.6651.58.camel@perches.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
	 <1416692961.7215.31.camel@decadent.org.uk>
	 <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416705859.17888.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <547210EF.9030800@mellanox.com>
	 <1416762320.17888.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:53349 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752357AbaKWU4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 15:56:37 -0500
In-Reply-To: <1416762320.17888.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-23 at 09:05 -0800, Eric Dumazet wrote:
> On Sun, 2014-11-23 at 18:53 +0200, Amir Vadai wrote:
> > >  	 */
> > >  	for (i = 0; i < priv->rx_ring_num; i++) {
> > > +		if (!ring_index)
> > > +			continue;
> > 
> > Why didn't you put the whole loop under the 'if'?
> 
> To avoid adding one indentation on the block, and ease this code review.
> 
> This is hardly fast path, and compiler does the optim for us anyway.

It might have been more sensible
to use break instead of continue
