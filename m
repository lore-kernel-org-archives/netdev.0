From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] tcp: Fix a connect() race with timewait sockets
Date: Wed, 2 Dec 2009 14:32:13 +0300
Message-ID: <20091202113213.GA18453@ioremap.net>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net> <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kdakhane@gmail.com,
	netdev@vger.kernel.org, netfilter@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:32770 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbZLBLcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 06:32:08 -0500
Content-Disposition: inline
In-Reply-To: <4B164293.7070804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2009 at 11:33:55AM +0100, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> You need several threads, using sockets with REUSEADDR set,
> and bind() to same address/port before connect() to same target.
> 
> We need another patch to correct this.
> 
> I wonder if always hold lock before calling check_established()
> would be cleaner.

Isnt this a too big overhead?

-- 
	Evgeniy Polyakov
