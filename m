From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSEC: on behavior of acquire
Date: Sun, 03 Apr 2005 17:52:26 +0200
Message-ID: <4250113A.4080202@trash.net>
References: <1112405144.1096.33.camel@jzny.localdomain>	 <20050402140019.GA13017@yakov.inr.ac.ru> <1112478168.1088.337.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112478168.1088.337.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Herbert also mentions something along the same lines in his email. 
> This would make a lot of sense!
> Is the state machine going to look something along the same lines as
> ARP? i.e incomplete->reachable etc?

Yes, from a bundle POV. In my current approach a single state is
resolved at a time and resolution is driven by XFRM_STATE_ACQ->*
state transitions.

> What would be a good code to return when you queue the packet?

It should be transparent, so 0.

Regards
Patrick
