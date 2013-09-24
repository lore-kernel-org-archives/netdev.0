From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 09:46:25 -0700
Message-ID: <1380041185.3165.97.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924160145.GB26769@order.stressinduktion.org>
	 <1380039299.3165.91.camel@edumazet-glaptop>
	 <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51761 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab3IXQq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:46:28 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so5191116pad.5
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:46:27 -0700 (PDT)
In-Reply-To: <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 09:35 -0700, Tom Herbert wrote:

> We should really be using rxhash for that anyway, eliminate this
> ehashfn.  This would entail adding rxhash argument in the various
> udp_lookup functions.

Nope : Some NICs provide UDP rxhash only using L3  (source IP,
destination IP), not L4 (adding source & destination ports)

This is again a case where we want our own hashing.
