From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 17:23:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4148B2E5.50106@pobox.com>
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
> On Wed, 15 Sep 2004 17:08:18 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>There's nothing inherently wrong with sticking a computer running
>>Linux inside another computer ;-)
> 
> 
> And we already support that :-)
> 
> Plus we have things like TSO too but that doesn't require a full Linux
> instance to realize on a networking port.
> Simple silicon implements this already.
> I don't see how that differs from your "big MTU" ideas.


Part of this is about how to talk to business people.... marketing.

The typical definition of TOE is "offload 90+% of the net stack", as 
opposed to "TCP assist", which is stuff like TSO.

If people ask about how to support TOE in Linux, you can say "sure, we 
_already_ support TOE, just stick Linux on a PCI card" rather than "no 
we don't support it."

And wha-la, we support TOE with zero code changes ;-)

	Jeff, who would love to have a bunch of Athlons
	on PCI cards to play with.
