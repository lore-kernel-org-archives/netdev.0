From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: 6to4/SIT and IP DF
Date: Wed, 15 Oct 2003 22:21:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF32DA07F2.CE83636D-ON88256DC1.001CC44C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: pekkas@netcore.fi, r.venning@telstra.com, nate@thebog.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





That doesn't sound terrible, but won't it have to drop a minimum of
2 packets per tunnel on an MTU change (or initial probe with a large
packet)?

So, it wouldn't be a good idea to connect multiple v6 clouds in series,
with
6to4 tunnels between them and decreasing MTU's and then try to send a
large packet from one end to the other; you might run out of retransmits
before
you get to the other end. :-)

But using v4 PMTU info is probably almost always better than fragmenting
everything. A "fragment, but tell me about it" ICMP message would come in
handy here. And a requirement that ICMPv4 with tunnels include encapsulated
headers +8.

Thanks, Dave,
                  +-DLS
