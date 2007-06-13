From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Tue, 12 Jun 2007 17:16:03 -0700
Message-ID: <20070612171603.47736395@localhost>
References: <20070512120739.371ada4f.billfink@mindspring.com>
	<649aecc70705120945q58ae79c9r8ff2dc5557658d1e@mail.gmail.com>
	<20070516024409.53049682.billfink@mindspring.com>
	<20070612.151258.120619253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, sangtae.ha@gmail.com, rhee@eos.ncsu.edu,
	rhee@ncsu.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49456 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752146AbXFMAQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 20:16:31 -0400
In-Reply-To: <20070612.151258.120619253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Jun 2007 15:12:58 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Bill Fink <billfink@mindspring.com>
> Date: Wed, 16 May 2007 02:44:09 -0400
> 
> > [root@lang2 ~]# netstat -s | grep -i retrans
> >     25446 segments retransmited
> >     20936 fast retransmits
> >     4503 retransmits in slow start
> >     4 sack retransmits failed
> > 
> > It then only took 2.14 seconds to transfer 1 GB of data.
> > 
> > That's all for now.
> 
> Thanks for all of your testing and numbers Bill.
> 
> Inhong et al., we have to do something about this, the issue
> has been known and sitting around for weeks if not months.
> 
> How safely can we set the default initial_ssthresh to zero in
> Cubic and BIC?

Yes. set it to zero. The module parameter could even go, and just
leave the route metric as a way to set/remember it.
