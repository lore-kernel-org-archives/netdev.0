From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [RTNETLINK] Tunnel config via netlink (Was Re: Convert RTM_* to
 enum)
Date: Thu, 16 Sep 2004 12:08:54 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409161129590.24531@rhea.tcs.hut.fi>
References: <20040915020942.GA32721@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040915020942.GA32721@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004, Herbert Xu wrote:

> I decided to bite the bullet and use netlink for the tunnel operations.

It's great if you have the time and energy to do this! Let me know if I
can be of any assistance with the ip6_tunnel.c modifications.

While designing the netlink interface it might perhaps be a good idea to
take a look at draft-ietf-ipv6-inet-tunnel-mib-02.txt, which is currently
in IESG processing. The IPv6 specific tunnel encapsulation limit (below)
is still missing from the draft but will be included in the RFC.

tunnelIfEncapsLimit OBJECT-TYPE
    SYNTAX     Integer32 (-1 | 0..255)
    MAX-ACCESS read-write
    STATUS     current
    DESCRIPTION
            "The maximum number of additional encapsulations permitted
            for packets undergoing encapsulation at this node.  A value
            of -1 indicates that no limit is present (except as a result
            of the packet size)."
    REFERENCE  "RFC 2473, section 4.1.1"
    ::= { tunnelIfEntry 11 }

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
