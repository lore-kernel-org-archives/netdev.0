From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Wed, 29 Oct 2014 15:34:38 +0100
Message-ID: <1414593278.24008.20.camel@localhost>
References: <1414487474-18201-1-git-send-email-ek@google.com>
	 <CAKD1Yr2PSJ0=YV4m5jPyvt6cvNv8+-joft6L2DxO_5YLH6C7AQ@mail.gmail.com>
	 <CAAedzxptbKLrO_0uPVqXiqOACqNNj9BeeakgB3+t+XxemeN3Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Lorenzo Colitti <lorenzo@google.com>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:40340 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932834AbaJ2Oek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 10:34:40 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 4948B208DD
	for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 10:34:40 -0400 (EDT)
In-Reply-To: <CAAedzxptbKLrO_0uPVqXiqOACqNNj9BeeakgB3+t+XxemeN3Sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Erik,

On Mi, 2014-10-29 at 18:34 +0900, Erik Kline wrote:
> Given that we spoke about this reduction in the number of netlink messages
> earlier, do you still think it's an issue?

No, it would be nice to have but as this is just a minor detail and
complexity would be too high I am fine with your current solution.

> The end result here is that for listeners on netlink sockets on systems
> that (a) have optimistic dad built-in, (b) have optimistic dad enabled, and
> (c) have use_optimistic set: they'll 2 notifications (with different flags)
> for automatically added addresses on these interfaces.

Ack, I see.

> (Personally, given that we appear to send an RTM_NEWADDR when the address
> gets deprecated (I think), I think sending one on every flag change of
> interest is in keeping with existing behaviour.)

It does make sense, I have no objections.

Bye,
Hannes
