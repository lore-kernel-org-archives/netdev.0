From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 17:16:41 +0300
Message-ID: <20050212141641.GA27456@yakov.inr.ac.ru>
References: <0525M9211@server5.heliogroup.fr> <20050211150420.74737b2e@dxpl.pdx.osdl.net> <20050211170740.2608419b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, hubert.tonneau@fullpliant.org,
        romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru, niv@us.ibm.com,
        rick.jones2@hp.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050211170740.2608419b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This set of data frames you quoted are all full, and
> are tightly interspaced.  It looks exactly like a TSO
> frame, which we certainly set PSH on, but the TSO
> engine is dropping it aparently.
> 
> I guess this is e1000.  Any e1000 internals experts reading
> here who can comment on how e1000's TSO engine treats the
> PSH flag?

Or it was two one-segment frames.

Before blaming on e1000 it would be easier to confirm that
linux never worked with MacOS X, except for those kernels which
had congestion avoidance mostly supppressed.

I.e. let's disable TSO in 2.6.9 and look.

Alexey
