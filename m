From: Thomas Graf <tgraf@suug.ch>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 12:32:36 +0100
Message-ID: <20041110113236.GM31969@postel.suug.ch>
References: <41917330.6090002@trash.net> <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch> <20041110014125.GA7302@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41917330.6090002@trash.net> <20041110014125.GA7302@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20041110014125.GA7302@gondor.apana.org.au> 2004-11-10 12:41
> On Wed, Nov 10, 2004 at 02:39:41AM +0100, Thomas Graf wrote:
> > that once this is true it would work perfectly fine, however I 
> > think it would be inefficient to parse the whole TLV tree multiple
> > times.
> 
> Well it's only going to happen once for each module so that's no
> big deal.

* Patrick McHardy <41917330.6090002@trash.net> 2004-11-10 02:47
> It will only happen once for every module, so I don't think
> it's a big deal.

Agreed. I'm used to huge filter configurations up to 100 MiB per
netlink message and therefore I do care whether such as message is
parsed 1 times or 5 times since it's a matter of having the
network blocked for 3 or 15 seconds. However, if it helps to clean
up the error paths then I'll be very happy and do a workaround
for my special case if I ever need loadable modules.
