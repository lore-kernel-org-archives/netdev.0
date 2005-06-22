From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 23 Jun 2005 01:13:00 +0200
Message-ID: <20050622231300.GC14251@wotan.suse.de>
References: <20050622.132241.21929037.davem@davemloft.net> <200506222242.j5MMgbxS009935@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David S. Miller'" <davem@davemloft.net>, ak@suse.de, hadi@cyberus.ca,
        becker@scyld.com, rick.jones2@hp.com, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@neterion.com>
Content-Disposition: inline
In-Reply-To: <200506222242.j5MMgbxS009935@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> This is very hw-dependent, since there are NICs that read descriptors in
> batches anyways - but the second argument below is compelling.

The computing time must be quite long to be really a win.
You need to waste a few hundred cycles at least on a modern fast CPU.

-Andi
> > 
> > 2) As shown above, it gives you compute time which can be used to
> >    schedule the prefetch.  This nearly makes RX replenishment free.
> >    Instead of having the CPU spin on a cache miss when we run
> >    eth_type_trans() during those cycles, we do useful work.
