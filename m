From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Thu, 18 Sep 2014 20:57:25 +0200
Message-ID: <20140918205725.64ddd4a7@redhat.com>
References: <20140917152653.1c824a22@redhat.com>
	<1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
	<5419A1E7.8040109@intel.com>
	<20140918085640.0815df6d@redhat.com>
	<1411047209.7106.255.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411047689.7106.258.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411054951.7106.272.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140918175910.5fc67efa@redhat.com>
	<1411058064.7106.277.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753874AbaIRS5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 14:57:33 -0400
In-Reply-To: <1411058064.7106.277.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 18 Sep 2014 09:34:24 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-09-18 at 17:59 +0200, Jesper Dangaard Brouer wrote:
> > On Thu, 18 Sep 2014 08:42:31 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
[...]
> > I'm looking for some 1G hardware without multiqueue, so I can get
> > around this measurement constraint.  And possibly turning it down to
> > 100Mbit/s, so I can more easily measure the HoL blocking effect.
> > 
> 
> ethtool -L   eth0    rx 1 tx 1 
> 
> (Or similar if combined is used)

Thanks! - that solves my qdisc measurement problem :-)
And yes, I had to use:

 ethtool -L eth1 combined 1

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
