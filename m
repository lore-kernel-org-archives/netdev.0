From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] iproute2 updates
Date: Fri, 4 Mar 2005 14:26:53 +0100
Message-ID: <20050304132653.GF31837@postel.suug.ch>
References: <20050304023520.GD31837@postel.suug.ch> <1109908154.1091.486.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1109908154.1091.486.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1109908154.1091.486.camel@jzny.localdomain> 2005-03-03 22:49
> On Thu, 2005-03-03 at 21:35, Thomas Graf wrote:
> > Stephen,
> > 
> > You may pull the following changes from bk://tgr.bkbits.net/iproute2-tgr-fix
> 
> Other than NPROBES change, shouldnt the other changes be reflective of
> whats in the kernel? This is the cost of keeping private headers. My
> suggestions would be to let Steve on every major release to just sync
> the header files.

Well, these are not exact copies, all the __KERNEL__ stuff is missing, a
few CONFIG ifdefs must be cut out and a few extra bits such as u32 mark
structures. I updated them because some of the structures were outdated.
I do not care how it is done but it required an update.

> PS:- Also on you 1/2 changes - I notice one bug fix, the rest seems
> cosmetic - what does that buy you? Does it make the code more readable
> etc?

Yes, it improves readability a lot, I first thought the neighbour code
had a bug until I read the code bit by bit from the top and there was
quite some logic in it that one wouldn't expect such as parallel code
paths for errors and normal execution. I replacted the rta_len checks
with RTA_PAYLOAD and adapted the logic to be like the rest of the
rtnetlink handle code.
