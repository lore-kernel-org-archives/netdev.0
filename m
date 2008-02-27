From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
	netif_rx()
Date: Wed, 27 Feb 2008 07:34:15 +0000
Message-ID: <20080227073415.GB4000@ff.dom.local>
References: <20080226.182120.183405235.davem@davemloft.net> <20080227072041.GA4000@ff.dom.local> <20080226.232314.130964666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52432 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbYB0HdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 02:33:11 -0500
Received: by ug-out-1314.google.com with SMTP id z38so208947ugc.16
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 23:33:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080226.232314.130964666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 11:23:14PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 27 Feb 2008 07:20:41 +0000
> 
> > I wonder why overloading with net processing is no concern here?
> > There would be no napi control around this  netif_receive_skb().
> 
> Good point, but we're talking about loopback wherein only
> the local system can overload itself.

Then e.g. the lack of responsiveness should concern us, I guess.

Jarek P.
