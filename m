From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 18:31:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4148C2B0.20504@pobox.com>
References: <4148991B.9050200@pobox.com>	<Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>	<1095275660.20569.0.camel@localhost.localdomain>	<4148A90F.80003@pobox.com>	<20040915140123.14185ede.davem@davemloft.net>	<20040915210818.GA22649@havoc.gtf.org> <20040915141346.5c5e5377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, paul@clubi.ie, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040915141346.5c5e5377.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Plus we have things like TSO too but that doesn't require a full Linux
> instance to realize on a networking port.
> Simple silicon implements this already.
> I don't see how that differs from your "big MTU" ideas.


WRT MTU:  if the card is a buffering endpoint, rather than a 
passthrough, the card deals with Path MTU and fragmentation, leaving the 
card<->host MTU at 64K, getting nice big fat frames.

	Jeff
