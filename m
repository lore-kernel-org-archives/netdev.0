From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict
 verification
Date: Sun, 5 Jul 2009 08:52:03 +0930
Message-ID: <20090705085203.332f0c3b.lk-netdev@lk-netdev.nosense.org>
References: <200907030246.18054.denys@visp.net.lb>
	<200907041803.25436.denys@visp.net.lb>
	<m13a9c6rhv.fsf@fess.ebiederm.org>
	<200907050100.08148.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:43697 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbZGDXWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 19:22:06 -0400
In-Reply-To: <200907050100.08148.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 5 Jul 2009 01:00:08 +0300
Denys Fedoryschenko <denys@visp.net.lb> wrote:

> On Sunday 05 July 2009 00:57:32 Eric W. Biederman wrote:
> >
> > How can that possibly be a correct network configuration?
> >
> > Eric
> It is a problem to have different networks, who doesn't communicate one with 
> each other, in same ethernet segment?
> 
> Does it violate anything?

I'm pretty sure it doesn't.

It's a common enough situation. A second subnet (or more) is assigned
to a link because the first isn't large enough, and renumbering the
hosts into a larger subnet is not practical at the time. A
'one-armed router' is used up stream to have traffic go between the
different subnets, at the cost of traffic double traversing the link.
(The worst example I've seen is 25 subnets operating this way!)

Fundamentally it is no different to routing traffic to other subnets.
IP was designed on the assumption that there'd only be a single subnet
per link, so nothing was done to make this scenario more efficent.

IPv6 has introduced the ability for hosts to be told by their default
router that destinations they think are "offlink", because the address
falls outside a locally assigned or learned prefixes, are actually
"onlink", preventing this double traversing problem.

Regards,
Mark.


