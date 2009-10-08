From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Thu, 8 Oct 2009 12:00:39 +0000
Message-ID: <20091008120039.GA8691@ff.dom.local>
References: <4ACD9255.4020008@gmail.com> <20091008090344.GA7409@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:63706 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757927AbZJHMBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 08:01:22 -0400
Received: by fxm27 with SMTP id 27so5440114fxm.17
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2009 05:00:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091008090344.GA7409@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 08, 2009 at 09:03:44AM +0000, Jarek Poplawski wrote:
...
> num_tx_queues. But it seems we should rather use more often
> real_num_tx_queue in schedulers code like dumps and maybe more
> (like e.g. sch_multiq does).

...i.e. probably everywhere between dev_activate and dev_deactivate
all qdisc operations could use real_num_tx_queues (including a test
like: netif_is_real_multique), unless I miss something.

Jarek P.
