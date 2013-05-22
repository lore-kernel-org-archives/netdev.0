From: Flavio Leitner <fbl@redhat.com>
Subject: Re: possible bug in IPv6 MLD retransmissions
Date: Wed, 22 May 2013 18:21:27 -0300
Message-ID: <20130522212127.GF17259@obelix.rh>
References: <20130517032449.GA3595@obelix.rh>
 <20130518173105.GD29528@order.stressinduktion.org>
 <20130521150616.GA8513@obelix.rh>
 <20130522004027.GD32093@order.stressinduktion.org>
 <OF1A7F184A.4282AFE8-ON85257B73.003E82A8-85257B73.003F3B88@us.ibm.com>
 <20130522172711.GC17240@obelix.rh>
 <OF2FF7FDBF.29F92AB4-ON85257B73.00649006-85257B73.00652081@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204Ab3EVVVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 17:21:35 -0400
Content-Disposition: inline
In-Reply-To: <OF2FF7FDBF.29F92AB4-ON85257B73.00649006-85257B73.00652081@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 02:24:34PM -0400, David Stevens wrote:
> Flavio Leitner <fbl@redhat.com> wrote on 05/22/2013 01:27:11 PM:
> 
> > It becomes a bug (and that's why I started with 'possible') if dad
> > completes after the two MLD reports sent with ``::'' source, because
> > routers will ignore those initial reports and the system is left out.
> 
> No, unsolicited reports are not necessary for MLD. If there are no
> other listeners for a group, the reports will be triggered within
> one query interval after a valid LL addr is there.

Agreed that they aren't necessary, but I also don't think it's
a good solution to wait for the query interval.

-- 
fbl
