From: Wichert Akkerman <wichert@wiggy.net>
Subject: Re: ipv6 tunnel stops accepting input
Date: Sat, 15 Jan 2005 13:44:11 +0100
Message-ID: <20050115124411.GA20912@wiggy.net>
References: <20050111125826.GA25169@wiggy.net> <20050115120323.GA20664@wiggy.net> <20050115122912.GA29331@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050115122912.GA29331@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously Herbert Xu wrote:
> Hmm, is it still happening now?

Seems to work just fine now.

> Are you using a SIT tunnel? Do you allow SIT traffic initiated
> from the outside?

Hmm, that might indeed be the problem and would explain the behaviour:
generating outgoing traffic adds a connection and from that point
incoming traffic would hit the RELATED accept rule.

I'll redo the firewall rules a bit and see if things improve.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
