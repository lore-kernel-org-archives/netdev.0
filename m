From: David Miller <davem@davemloft.net>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 01:57:56 -0700 (PDT)
Message-ID: <20100415.015756.67917222.davem@davemloft.net>
References: <1271276855.16881.1756.camel@edumazet-laptop>
	<z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	<1271278661.16881.1761.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, hadi@cyberus.ca, shemminger@vyatta.com,
	netdev@vger.kernel.org, robert@herjulf.net, xiaosuo@gmail.com,
	andi@firstfloor.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53728
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757499Ab0DOI5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:57:52 -0400
In-Reply-To: <1271278661.16881.1761.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Apr 2010 22:57:41 +0200

> RPS can be tuned (Changli wants a finer tuning...), it would be
> intereting to tune multiqueue devices too. I dont know if its possible
> right now.

Only NIU allows real detailed control over queue selection and
stuff like that, because the hardware has a real TCAM for
packet matching and packets which match in TCAM entries can
steer to different collections of queues.

We have ethtool interfaces for this (ETHTOOL_GRXCLS*), so you can
change it.

For most other chips we only have interfaces for modifying the
RX hashing algorithm or what the RX hash covers, stuff like
that.

See also ETHTOOL_GRXFH, ETHTOOL_SRXFH, ETHTOOL_SRXNTUPLE, and
ETHTOOL_GRXNTUPLE, the latter two of which were added for Intel
NICs.
