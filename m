From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 10:37:54 -0700
Message-ID: <5241CDF2.1020601@hp.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop> <20130924160145.GB26769@order.stressinduktion.org> <1380039299.3165.91.camel@edumazet-glaptop> <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com> <1380041185.3165.97.camel@edumazet-glaptop> <CA+mtBx_tWS44q8jER+QtR5k4k2ieq99He6YdPF8KKBF4Z2+32w@mail.gmail.com> <1380044075.3165.108.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:48696 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab3IXRh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 13:37:59 -0400
In-Reply-To: <1380044075.3165.108.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2013 10:34 AM, Eric Dumazet wrote:
> If you have multiqueue NIC, you do not use RPS/RFS, so skb->rxhash might
> be 0

If one has a CPU count >> the NIC queue count, mightn't one still want 
to use RPS/RFS?

rick jones
