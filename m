From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net-qdisc-hhf: Heavy-Hitter Filter (HHF) qdisc
Date: Thu, 19 Dec 2013 11:40:36 -0800
Message-ID: <1387482036.19078.371.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386746796-490-1-git-send-email-vtlam@google.com>
	 <1387096221-20112-1-git-send-email-vtlam@google.com>
	 <20131219.143045.472862795767521855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vtlam@google.com, netdev@vger.kernel.org, nanditad@google.com,
	edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:57717 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab3LSTkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:40:39 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so1584557pab.41
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 11:40:38 -0800 (PST)
In-Reply-To: <20131219.143045.472862795767521855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 14:30 -0500, David Miller wrote:
> From: Terry Lam <vtlam@google.com>
> Date: Sun, 15 Dec 2013 00:30:21 -0800
> 
> > This patch implements the first size-based qdisc that attempts to
> > differentiate between small flows and heavy-hitters.  The goal is to
> > catch the heavy-hitters and move them to a separate queue with less
> > priority so that bulk traffic does not affect the latency of critical
> > traffic.  Currently "less priority" means less weight (2:1 in
> > particular) in a Weighted Deficit Round Robin (WDRR) scheduler.
> 
> Can someone please review this, thanks!


I did, and somehow managed to not send the message :

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
