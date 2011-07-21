From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Thu, 21 Jul 2011 12:44:57 -0700
Message-ID: <20110721124457.72cb45e4@nehalam.ftrdhcpuser.net>
References: <20110719180222.GA7509@midget.suse.cz>
	<1311178905.21004.9.camel@dcbw.foobar.com>
	<20110720163656.GD11692@midget.suse.cz>
	<1311226254.3140.52.camel@dcbw.foobar.com>
	<1311266139.3059.9.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60534 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300Ab1GUTpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 15:45:00 -0400
In-Reply-To: <1311266139.3059.9.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jul 2011 11:35:37 -0500
Dan Williams <dcbw@redhat.com> wrote:

> > For problem #2, shouldn't a new RS be sent whenever the interface
> > changes it's IFF_LOWER_UP bit?  IFF_LOWER_UP indicates a carrier on/off
> > event and thus indicates possible disconnect/reconnect to a new network.
> > I don't specifically know how it works now, but if RS isn't triggered
> > from IFF_LOWER_UP, I'd imagine that either (a) something didn't get
> > updated when IFF_LOWER_UP became how carrier was indicated in 2.6.17
> > (commit b00055aacdb172c05067612278ba27265fcd05ce) or (b) there's a
> > reason IFF_LOWER_UP isn'

IFF_RUNING is used to indicate carrier, IFF_LOWER_UP is for layered
devices like vlan's but is rarely used.
