From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [RTNETLINK] Tunnel config via netlink (Was Re: Convert RTM_* to
 enum)
Date: Thu, 16 Sep 2004 14:13:40 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409161412290.32720-100000@netcore.fi>
References: <Pine.LNX.4.58.0409161129590.24531@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        James Morris <jmorris@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0409161129590.24531@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004, Ville Nuorvala wrote:
> While designing the netlink interface it might perhaps be a good idea to
> take a look at draft-ietf-ipv6-inet-tunnel-mib-02.txt, which is currently
> in IESG processing. The IPv6 specific tunnel encapsulation limit (below)
> is still missing from the draft but will be included in the RFC.
> 
> tunnelIfEncapsLimit OBJECT-TYPE
>     SYNTAX     Integer32 (-1 | 0..255)
>     MAX-ACCESS read-write
>     STATUS     current
>     DESCRIPTION
>             "The maximum number of additional encapsulations permitted
>             for packets undergoing encapsulation at this node.  A value
>             of -1 indicates that no limit is present (except as a result
>             of the packet size)."
>     REFERENCE  "RFC 2473, section 4.1.1"
>     ::= { tunnelIfEntry 11 }

FWIW, I've always viewed this as a mostly unnecessary feature that
nobody bothers to implement, but YMMV.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
