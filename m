From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Sun, 20 Feb 2005 21:40:48 -0600
Message-ID: <200502202140.48403.jdmason@us.ibm.com>
References: <200502161823.43562.jdmason@us.ibm.com> <4218CE73.6010206@phekda.gotadsl.co.uk> <20050221002827.GB14268@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050221002827.GB14268@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 20 February 2005 06:28 pm, Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
>
> > I started working on adding netif_msg checks to the printks. How far
> > have you got? I don't want to duplicate your work.
>
> None so far. Go wild.
>
> > Incidentally, is there a to-do list somewhere for the r8169 driver?
>
> (without priority)
>
> - validate suspend/resume/wol
>
> - fix the dac issues on x64
>   Weird. Pita. Status needs to be updated.
>
> - push jumbo frames beyond 7k
>   see with Jon Mason
>
> - merge with the 8139cp driver
>   always interrupted but I have not given up
>
> - fix the gcc 2.95.x miscompilations
>   people upgrade their compiler and return to real life before it can be
>   diagnosed. It should not be hard but I have not had the time to install
>   a broken debian to reproduce it so far :o(
>
> - benchmark/improve the performances
>   Executive summary by Lennert Buytenhek: it sucks. If someone could
> identify where the bottleneck is with hard numbers...
>
> - harvest the hopeless r8169 users on the web
>   time consuming like hell but it really helps to figure if things are
>   stable or not.
>
> - backport to 2.4
>   RSN. Pending queue is available here and will be pushed once 2.6.x is
>   up-to-date.
>
> - ask Ben Greear if he still experiences keyboard issues with its laptop
>   when he uses the r8169 driver
>   Pending for 5 months... Ahem.
>
> > Maybe I can help out with some of the things.
>
> Figure what's wrong with M. Gardiol setup ?

Fix ethtool statistics (amd64 only problem?)
