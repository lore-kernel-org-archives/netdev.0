From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [OOPS][3.12] BUG: unable to handle kernel NULL pointer
 dereference at 0000000c
Date: Sat, 23 Nov 2013 23:10:19 +0200
Message-ID: <20131123211019.GA7084@shutemov.name>
References: <CAErSpo4jh7pO=jhZTvHD+sT2O12Ly6V3e_oiac8gHqmdmqevkg@mail.gmail.com>
 <20131115.174426.1448825246187940374.davem@davemloft.net>
 <20131115233919.GB11450@pomac.netswarm.net>
 <20131115.185755.1752342950675745464.davem@davemloft.net>
 <20131118092255.GX31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pomac@demius.net,
	bhelgaas@google.com, pomac@vapor.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org, alex.aring@gmail.com,
	stable@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131118092255.GX31491@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 18, 2013 at 10:22:55AM +0100, Steffen Klassert wrote:
> On Fri, Nov 15, 2013 at 06:57:55PM -0500, David Miller wrote:
> > From: Ian Kumlien <pomac@demius.net>
> > Date: Sat, 16 Nov 2013 00:39:19 +0100
> > 
> > > On Fri, Nov 15, 2013 at 05:44:26PM -0500, David Miller wrote:
> > >> From: Bjorn Helgaas <bhelgaas@google.com>
> > >> Date: Fri, 15 Nov 2013 15:29:53 -0700
> > >> 
> > >> > [+cc David, Eric, Alex, netdev]
> > >> > 
> > >> > Alex reported a similar issue at
> > >> > http://marc.info/?l=linux-netdev&m=138355719901790&w=4
> > >> 
> > >> Fixed by:
> > >> 
> > >> commit 84502b5ef9849a9694673b15c31bd3ac693010ae
> > >> Author: Steffen Klassert <steffen.klassert@secunet.com>
> > >> Date:   Wed Oct 30 11:16:28 2013 +0100
> > > 
> > > Cherry-picked, compiled and preparing for reboot - thanks!
> > > 
> > > Shouldn't this be queued up in stable sometime soonish?
> > > 
> > > (Sorry for the change of email address, i had forgot to switch the
> > > configurations in mutt)
> > 
> > Steffen is in charge of IPSEC -stable submissions, please ask him
> > :-)
> 
> It was intended for v3.12 but the release came before it was merged
> into the manline. So yes, it should go to the v3.12 stable tree.
> 
> I've always did stable submissions just by marking them as a
> candidate for stable, this did not happen here because I hoped
> it will make it into v3.12. It should apply cleanly to v3.12
> stable, you could just pick it into you stable queue, or
> alternatively I can submit to stable.

Any progress with getting the patch into stable?

It's not in v3.12.1 and I don't see it in stable queue.

-- 
 Kirill A. Shutemov
