From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sat, 5 Mar 2005 02:20:49 +0100
Message-ID: <20050305012049.GL31837@postel.suug.ch>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch> <42290172.7020403@trash.net> <20050305010319.GB27804@gondor.apana.org.au> <42290738.6050605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42290738.6050605@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <42290738.6050605@trash.net> 2005-03-05 02:11
> Herbert Xu wrote:
> >On Sat, Mar 05, 2005 at 01:46:42AM +0100, Patrick McHardy wrote:
> >
> >>I think that would be ok. Unrelated to this: for IFA_ADDRESS we don't
> >>do an exact match, perhaps we should also do this for IFA_LOCAL for
> >>consistency.
> >
> >
> >You mean that we do do an exact match for IFA_ADDRESS?
> 
> No, I meant that IFA_ADDRESS matches on exact prefixlen, but uses
> inet_ifa_match() for comparing the addresses. In any case we should
> keep the behaviour that no given prefix is a wildcard, but if a
> prefix is given we could do something similar as for IFA_ADDRESS.

This will change the behaviour and makes my work completely useless.

Assuming one adds 1.1.1.1/24, 1.1.1.2/24 and then deletes 1.1.1.2/24
one would expect 1.1.1.2/24 to be deleted but that wouldn't be the
case.
