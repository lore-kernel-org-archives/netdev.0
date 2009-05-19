From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH: 2.6.29] tcp_vegas.c ssthresh bug fix
Date: Tue, 19 May 2009 12:22:15 -0700 (PDT)
Message-ID: <20090519.122215.106629250.davem@davemloft.net>
References: <20090519101643.GA12429@scriptng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: doug.leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751979AbZESTWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:22:17 -0400
In-Reply-To: <20090519101643.GA12429@scriptng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <doug.leith@nuim.ie>
Date: Tue, 19 May 2009 11:16:43 +0100

> --- 2.6.29-rc5/net/ipv4/tcp_vegas.c.orig	2009-04-27 12:55:18.000000000 +0100
> +++ 2.6.29-rc5/net/ipv4/tcp_vegas.c	2009-05-19 11:03:41.000000000 +0100
> @@ -224 +224 @@ static void tcp_vegas_cong_avoid(struct 
> -			if (diff > gamma && tp->snd_ssthresh > 2 ) {
> +			if (diff > gamma && tp->snd_cwnd <= tp->snd_ssthresh) {
> @@ -228 +227,0 @@ static void tcp_vegas_cong_avoid(struct 
> -				tp->snd_ssthresh = 2;
> @@ -252,0 +252 @@ static void tcp_vegas_cong_avoid(struct 
> +					tp->snd_ssthresh = min(tp->snd_ssthresh, tp->snd_cwnd-1);

This patch is severely corrupted by your email client, or by something
else, and it's therefore not going to apply to anything.

Please read carefully Documentation/email-clients.txt and
Documentation/SubmittingPatches before trying to submit this
again.

Thank you.
