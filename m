From: Martin Lucina <mato@kotelna.sk>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Fri, 22 Sep 2006 20:29:25 +0200
Message-ID: <20060922182924.GE4161@dezo.moloch.sk>
References: <20060922112442.GB4161@dezo.moloch.sk> <20060922095642.5acf4ac9@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:18352 "EHLO mail.moloch.sk")
	by vger.kernel.org with ESMTP id S964869AbWIVS30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 14:29:26 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060922095642.5acf4ac9@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@osdl.org said:
> You can turn off TX pause and get the same effect.

Not sure if I did the right thing, but:

# ifdown eth1
...
# ethtool -A eth1 tx off
# ethtool -a eth1
Pause parameters for eth1:
Autonegotiate:	on
RX:		on
TX:		off
# ifup eth1
...
sky2 eth1: enabling interface
sky2 eth1: Link is up at 1000 Mbps, full duplex, flow control both
# ethtool -a eth1
Pause parameters for eth1:
Autonegotiate:	on
RX:		on
TX:		on

is this what I should be seeing?

-mato
