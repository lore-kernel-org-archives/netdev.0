From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sky2: hw checksum failures
Date: Wed, 06 Sep 2006 07:56:54 +1000
Message-ID: <1157493415.22705.145.camel@localhost.localdomain>
References: <1157416603.22705.62.camel@localhost.localdomain>
	 <20060904203442.1c9ed2eb@localhost.localdomain>
	 <1157427758.22705.65.camel@localhost.localdomain>
	 <20060904205645.6c80f30c@localhost.localdomain>
	 <1157431548.22705.78.camel@localhost.localdomain>
	 <44FD90FC.4090409@osdl.org>
	 <1157490763.22705.130.camel@localhost.localdomain>
	 <20060905143103.15842e07@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49087 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1751517AbWIEV5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 17:57:14 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060905143103.15842e07@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Agreed. Actually the checksum value is same hi/lo because there are
> two checksum units and we ask for the same offset on both.

Ok, that explains the (HLEN << 16) | HLEN thing when configuring it...
At this point, best is I dig into the actual values and see what's up.
I'll let you know (I don't have the HW at hand right now)

Ben.


