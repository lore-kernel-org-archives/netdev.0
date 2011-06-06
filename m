From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Mon, 6 Jun 2011 23:35:15 +0300
Message-ID: <20110606203515.GA2802@redhat.com>
References: <20110606035808.GA28858@redhat.com>
 <20110605.221537.899061768025493519.davem@davemloft.net>
 <20110606153253.GB30665@redhat.com>
 <20110606.122059.261517215690508151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maheshb@google.com, netdev@vger.kernel.org, therbert@google.com,
	mirqus@gmail.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756523Ab1FFUfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 16:35:01 -0400
Content-Disposition: inline
In-Reply-To: <20110606.122059.261517215690508151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2011 at 12:20:59PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Mon, 6 Jun 2011 18:32:53 +0300
> 
> > On Sun, Jun 05, 2011 at 10:15:37PM -0700, David Miller wrote:
> >> Since the GSO accessors deal with mutliple bits, you can create
> >> special GSO specific interfaces to manipulate them.
> > 
> > Yes but it's not just GSO.
> > It's anything that includes more than 1 feature.
> > Examples:
> > NETIF_F_ALL_CSUM
> > NETIF_F_ALL_TX_OFFLOADS
> > NETIF_F_V6_CSUM
> > NETIF_F_SOFT_FEATURES
> > 
> > etc
> > 
> > Creating many accessors for each will need a lot
> > of code duplication ...
> 
> Yet this is something you must resolve in order to change the feature
> bit implementation.
> 
> Whether this issue is difficult or not to address, it has to be done
> either way.

I think I found a truly elegant solution to this
problem which this margin is too narrow to contain ...

-- 
MST
