From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 09:35:54 -0700
Message-ID: <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	<1379980991.3165.37.camel@edumazet-glaptop>
	<20130924023038.GA22393@order.stressinduktion.org>
	<20130924033505.GB22393@order.stressinduktion.org>
	<1380001118.3165.41.camel@edumazet-glaptop>
	<20130924160145.GB26769@order.stressinduktion.org>
	<1380039299.3165.91.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36345 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab3IXQfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:35:54 -0400
Received: by mail-ie0-f169.google.com with SMTP id tp5so9518449ieb.0
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:35:54 -0700 (PDT)
In-Reply-To: <1380039299.3165.91.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 9:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-09-24 at 18:01 +0200, Hannes Frederic Sowa wrote:
>
>> inet(6)_ehashfn does get used by udp btw. But I do not understand the code,
>> yet. ;)
>
> Oh well, thats the SO_REUSEPORT thing. We do not really care, thats only
> used to try to steer udp flows on a given socket, but its a hint.
>
> Presumably it should use a separate secret key.
>
>
We should really be using rxhash for that anyway, eliminate this
ehashfn.  This would entail adding rxhash argument in the various
udp_lookup functions.
