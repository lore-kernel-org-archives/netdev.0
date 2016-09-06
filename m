From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Centralizing support for TCAM?
Date: Tue, 6 Sep 2016 15:31:05 +0200
Message-ID: <20160906133105.GD2719@lunn.ch>
References: <57d4a2db-ca3b-909a-073a-52ecceb428f2@gmail.com>
 <b8323295-e3eb-48ca-7c82-ff40d222a743@gmail.com>
 <57C9C9BE.6040407@gmail.com>
 <20160903070950.GA1749@nanopsycho.orion>
 <20160906034450.GA34929@ast-mbp.thefacebook.com>
 <4e871929-b8fb-b1c9-6909-218460e21e76@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, jiri@mellanox.com, idosh@mellanox.com,
        john.fastabend@intel.com, ast@kernel.org, davem@davemloft.net,
        ecree@solarflare.com, vivien.didelot@savoirfairelinux.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36279 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932893AbcIFNbP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 09:31:15 -0400
Content-Disposition: inline
In-Reply-To: <4e871929-b8fb-b1c9-6909-218460e21e76@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Since this thread about tcam... my 0.02 here is it's pretty bad in
> >the nic(host) due to power consumption and in the tor it's only good as
> >a part of algorithmic lpm solutions. There it won't be even seen as tcam.
> >Instead the fancy algorithms will use exact match + tcam + aux data to pack
> >as many routes into such 'algorithmic lpm' as possible, so I cannot see
> >what tcam as actual tcam can be good for.
> >
> 
> Agreed on tcams.

So if i'm reading this right, you are talking about big switches, top
of racks, etc. And you don't see much use for the TCAM.

Florian and I are interested in the other end of the scale. Little
5-10 port switches in SoHo, STB, WiFi Access points etc. At the
moment, firewalling in such devices is done by the CPU. If we can
offload some of the firewall rules to the TCAM, we would be happy.

	Andrew
