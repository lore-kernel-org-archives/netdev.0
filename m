From: Andreas =?iso-8859-1?Q?H=FCbner?= <andreas@k4n.de>
Subject: Re: icmpv6: issue with routing table entries from link local
 addresses
Date: Tue, 13 Sep 2016 11:22:42 +0200
Message-ID: <20160913092242.GK26782@targo.k4n.de>
References: <20160912142732.GI26782@targo.k4n.de>
 <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
 <bf36b487-1cdf-ede9-1ed8-cca17c7f5fc6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org, "d. caratti" <davide.caratti@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from targo.k4n.de ([213.133.103.195]:44687 "EHLO targo.k4n.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757551AbcIMJWu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 05:22:50 -0400
Content-Disposition: inline
In-Reply-To: <bf36b487-1cdf-ede9-1ed8-cca17c7f5fc6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 01:17:24PM -0600, David Ahern wrote:
> v4.4 and on there are fib6 tracepoints that show the lookup result.
> May provide some insights.
>
> perf record -a -e fib6:*
> perf script

Thanks for the hint, didn't now that something like this exists.

Following up on my earlier mail, I wasn't able to reproduce the issue
with more recent kernel versions. (tried 4.7)

So I guess someone must have fixed it somewhere between 3.16 and 4.7. :)
Okay, will check the git and probably try to backport it.

Again, sorry that I did not check immediately with the more recent kernel
versions. Wasn't expecting that much has changed in this area.

But my request for information with regard to the FIB data structure
still remains, since I'm curious about how it actually works.
(And I already spent some time trying to understand it.)


Thanks for your help, everyone!

Andreas
