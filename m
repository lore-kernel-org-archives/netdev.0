From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Tue, 21 Sep 2004 19:32:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921093252.GA32545@gondor.apana.org.au>
References: <20040918203319.24004d6e.davem@davemloft.net> <1095645106.1048.190.camel@jzny.localdomain> <20040919195351.0b3560e6.davem@davemloft.net> <1095686672.1049.301.camel@jzny.localdomain> <20040920121123.70baf895.davem@davemloft.net> <20040921034212.GA28462@gondor.apana.org.au> <20040920231805.3f18479c.davem@davemloft.net> <20040921090423.GE8058@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040921090423.GE8058@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2004 at 11:04:23AM +0200, Andi Kleen wrote:
> 
> I think you should remove the TOS support completely because
> it's obsolete with fwmark.  And maybe remove it will allow
> some tuning later.

If we were doing this from scratch then we should do that.  But as it
is we must keep the TOS code for compatibility.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
