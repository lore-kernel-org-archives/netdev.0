From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 05:19:59 +0400
Message-ID: <20050907011959.GA25725@yakov.inr.ac.ru>
References: <43014E27.1070104@cosmosbay.com> <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
Content-Disposition: inline
In-Reply-To: <20050906235700.GA31820@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

On Tue, Sep 06, 2005 at 04:57:00PM -0700, Simon Kirby wrote:
> On Fri, Aug 26, 2005 at 09:49:11PM +0200, Robert Olsson wrote:
...
> > I think Simon uses UP and it could be idea to check if the RCU deferred 
> > deletion causes the problem. 
..
> Yes, this is the difference.  With the patch applied (ajust directly
> freeing the dst_entry), everything balances easily, there are no
> overflows, and the result of rt_may_expire() looks very reasonable.
> (Yay!)
> 
> So, this seems to be the culprit.  Is NAPI supposed to allow the
> queued bh to run or should we just not be queuing this?

It is supposed to work. :-) The problem is like an unkillable zombie.

Robert, have you seen this pehonomenon already? Did you mean that SMP works
or that it never works (but this patch is valid only for UP)? Did it
become worse after 2.6.9?

Alexey
