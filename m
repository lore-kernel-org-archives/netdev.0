From: Martin Bouzek <martin.bouzek@radas-atc.cz>
Subject: Re: Minor IPSec bug + solution
Date: 20 Sep 2004 09:49:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095666589.2723.8.camel@mabouzek>
References: <E1C83f1-0002X7-00@gondolin.me.apana.org.au>
	 <1095413173.2708.106.camel@mabouzek>
	 <20040917102720.GA14579@gondor.apana.org.au>
Reply-To: martin.bouzek@radas-atc.cz
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040917102720.GA14579@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-17 at 12:27, Herbert Xu wrote:
> On Fri, Sep 17, 2004 at 11:26:13AM +0200, Martin Bouzek wrote:
> >
> > > > function. For tunnels it returns 
> > > > 
> > > > tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, family);
> > 
> > Well, I am not expierienced with the networking kernel code,
> > nevertheless I still think the check is not correct. 
> 
> If you change the && to ||, then an ESP tunnel SA marked as required
> can be matched by a simple IPIP SA with the same addresses.

Ok. And would it be possible to check the protocols too (eg.
tmpl->id.proto == x->id.proto)? If it is realy not possible to make the
IPComp/required tunnel to work, it would be nice to mention it in for
example the setkey man page. It could save quite lot of time to some
people. (like me :-) ).
