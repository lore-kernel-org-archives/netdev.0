From: Patrick McHardy <kaber@trash.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 06:07:31 +0100
Message-ID: <41F48293.9050301@trash.net>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124045635.GA30372@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, tgraf@suug.ch,
        david@davidcoulson.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050124045635.GA30372@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Another possibility is some bogus netfilter module that the
>reporter is using.  His backtrace was showing an ipq_kill which
>isn't in the main tree.
>
I was fooled by the name too, ipq_kill doesn't belong to ip_queue but
to net/ipv4/ip_fragment.c.

Regards
Patrick
