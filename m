From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 10:44:11 -0700
Message-ID: <1380044651.3165.109.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924160145.GB26769@order.stressinduktion.org>
	 <1380039299.3165.91.camel@edumazet-glaptop>
	 <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com>
	 <1380041185.3165.97.camel@edumazet-glaptop>
	 <CA+mtBx_tWS44q8jER+QtR5k4k2ieq99He6YdPF8KKBF4Z2+32w@mail.gmail.com>
	 <1380044075.3165.108.camel@edumazet-glaptop> <5241CDF2.1020601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:62943 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457Ab3IXRoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 13:44:13 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so4913199pdj.31
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 10:44:13 -0700 (PDT)
In-Reply-To: <5241CDF2.1020601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 10:37 -0700, Rick Jones wrote:
> On 09/24/2013 10:34 AM, Eric Dumazet wrote:
> > If you have multiqueue NIC, you do not use RPS/RFS, so skb->rxhash might
> > be 0
> 
> If one has a CPU count >> the NIC queue count, mightn't one still want 
> to use RPS/RFS?

Maybe, but UDP stack should not assume anything.

By the way, there is a problem with RFS under stress, I am cooking a
patch to address this.
