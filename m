From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] af_packet: allow disabling timestamps
Date: Wed, 19 Sep 2007 13:07:40 +0400
Message-ID: <20070919090739.GC30339@2ka.mipt.ru>
References: <1186669314.24669.56.camel@localhost.localdomain> <20070809143322.GA5345@2ka.mipt.ru> <1186683234.24669.65.camel@localhost.localdomain> <20070809181823.GA32449@2ka.mipt.ru> <1186685450.24669.81.camel@localhost.localdomain> <20070913124253.60da52f2@oldman> <20070913142406.299944c3.dada1@cosmosbay.com> <20070914122642.5343b128@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Unai Uribarri <unai.uribarri@optenet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47849 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbXISJIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 05:08:48 -0400
Content-Disposition: inline
In-Reply-To: <20070914122642.5343b128@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 14, 2007 at 12:26:42PM +0200, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> No, then we end up timestamping all the packets, even if they get dropped by
> packet filter. The change in 2.6.24 allows dhclient (and rstp) to only call
> hires clock source for packets they want, not all packets.
> 
> Perhaps the timestamping needs to change into a tristate flag?

Sorry for late reply - the situation we need to workaround (if I
uderstood correctly) is to disable timestamp when there are packet
sockets. Why tristate flag should ever be used?

-- 
	Evgeniy Polyakov
