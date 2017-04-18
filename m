From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Tue, 18 Apr 2017 16:09:02 -0700
Message-ID: <20170418230900.GC65449@ast-mbp.thefacebook.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
 <20170413042036.GA46229@ast-mbp.thefacebook.com>
 <1492063856.19193.4.camel@sipsolutions.net>
 <20170413.113810.703136630867928001.davem@davemloft.net>
 <20170414194105.GA51147@ast-mbp.thefacebook.com>
 <1492508879.2472.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36611 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758179AbdDRXJM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 19:09:12 -0400
Content-Disposition: inline
In-Reply-To: <1492508879.2472.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 11:47:59AM +0200, Johannes Berg wrote:
> > I guess any driver that would care about XDP performance would either
> > implement in-driver XDP or make sure that skb_linearize() doesn't
> > happen in generic XDP by doing build_skb() with the whole packet.
> > The driver can be smart and avoid doing copy-break if generic XDP is
> > on.
> 
> Indeed. I think this is less about performance than ease of
> experimentation.

yes. I'm bringing it up only to hopefully find cases where this
generic XDP can be used for real data path too (and not only experimentation).
Like if it can do 6Mpps whereas in-driver XDP will do 20Mpps (when implemented),
for some folks it may be good enough already to start using it.
Which will put more pressure on NIC vendor to implement it.
