From: Lincoln Dale <ltd@cisco.com>
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 19:29:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040916192213.04240008@171.71.163.14>
References: <20040915141346.5c5e5377.davem@davemloft.net>
 <4148991B.9050200@pobox.com>
 <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
 <1095275660.20569.0.camel@localhost.localdomain>
 <4148A90F.80003@pobox.com>
 <20040915140123.14185ede.davem@davemloft.net>
 <20040915210818.GA22649@havoc.gtf.org>
 <20040915141346.5c5e5377.davem@davemloft.net> <4148B2E5.50106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: alan@lxorguk.ukuu.org.uk, paul@clubi.ie, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4148B2E5.50106@pobox.com>
References: <20040915141346.5c5e5377.davem@davemloft.net>
 <4148991B.9050200@pobox.com>
 <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
 <1095275660.20569.0.camel@localhost.localdomain>
 <4148A90F.80003@pobox.com>
 <20040915140123.14185ede.davem@davemloft.net>
 <20040915210818.GA22649@havoc.gtf.org>
 <20040915141346.5c5e5377.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

not that i disagree with the general idea and rationale, but reality is 
what it is today for some reasons:

At 07:23 AM 16/09/2004, Jeff Garzik wrote:
>         Jeff, who would love to have a bunch of Athlons
>         on PCI cards to play with.

. . . this ignore the realities of power restrictions of PCI today . . .
sure, one could create a PCI card that takes a power-connector, but that 
don't scale so well either . . .

At 07:29 AM 16/09/2004, David S. Miller wrote:
>I think a better goal is "offload 90+% of the net stack cost" which
>is effectively what TSO does on the send side.
>
>This is why these discussions are so circular.

TSO works on LAN-like environments (zero latency, minimal drop), it doesn't 
work so well across the internet . . .

i believe that there are better alternatives than TSO, but it involves NICs 
having decent scatter-gather DMA engines and being able to be handled 
multiple transactions (packets/frames) at once.
in theory, NICs like tg2/tg3 should be capable of implementing something 
like this -- if one could get to the ucode on the embedded cores.


at least with PCI Express the general architecture of a PC starts to have a 
hope of keeping up with Moore's law.
the same couldn't be said prior to DDR-SDRAM and higher front-side-bus 
frequencies.


cheers,

lincoln.
