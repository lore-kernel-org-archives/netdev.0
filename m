From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] pktgen: add flag NO_TIMESTAMP to disable
 timestamping
Date: Fri, 29 Aug 2014 21:02:54 +0200
Message-ID: <20140829210254.360f74bf@redhat.com>
References: <20140828161447.6652.59388.stgit@dragon>
	<1409329026.3173.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Robert Olsson <robert@herjulf.se>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753382AbaH2TDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 15:03:10 -0400
In-Reply-To: <1409329026.3173.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Aug 2014 09:17:06 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2014-08-28 at 18:14 +0200, Jesper Dangaard Brouer wrote:
> > Then testing the TX limits of the stack, then it is useful to
> > be-able to disable the do_gettimeofday() timetamping on every packet.
> > 
> > This implements a pktgen flag NO_TIMESTAMP which will disable this
> > call to do_gettimeofday().
> > 
> > The performance change on (my system E5-2695) with skb_clone=0, goes
> > from TX 2,423,751 pps to 2,567,165 pps with flag NO_TIMESTAMP. Thus,
> > the cost of do_gettimeofday() or saving is approx 23 nanosec.
> 
> I guess using local_clock() would provide an accurate and less expensive
> timestamp, if a timestamp is needed.

Sure, but I don't need this timestamp, thus I added an option to disable it.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
