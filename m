From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 18:52:10 -0500
Message-ID: <20091113235210.GR19478@kvack.org>
References: <200911130701.14847.opurdila@ixiacom.com> <4AFCF8D3.6090905@gmail.com> <20091112222608.79d90e9e@nehalam> <200911131151.31677.opurdila@ixiacom.com> <20091113142939.35879efe@s6510> <20091113224043.GP19478@kvack.org> <20091113144937.23693bb4@nehalam> <20091113233504.GQ19478@kvack.org> <20091113153924.6130135f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:48311 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932313AbZKMXwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:52:05 -0500
Content-Disposition: inline
In-Reply-To: <20091113153924.6130135f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 03:39:24PM -0800, Stephen Hemminger wrote:
> Well TCP handles lots of connections, but a socket has different overhead
> than a network device. Why should 10Gbps need 10K PPPoE sessions?
> Even Vlan's are less overhead than PPP

PPP's overhead is acceptable.  It makes managing networks a lot easier, since 
the authentication done by PPP is able to look up any end user specific 
information required (ie static ips and routes), while the access part of 
the network is a fairly generic config that uses switchs and things like the 
GVRP.  Without that, the configuration of any aggregation switch becomes a 
huge management nightmare.

If you don't want the overhead from this kind of scaling, stick it under a 
config option, but please don't stop other people from pushing Linux into 
new uses which have these scaling requirements.

		-ben
