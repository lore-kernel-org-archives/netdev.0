From: Marc Herbert <marc.herbert@free.fr>
Subject: Re: [RFC] ethtool semantics
Date: Mon, 14 Jun 2004 15:11:15 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406141458270.16762@fcat>
References: <20040607212804.GA17012@k3.hellgate.ch> <20040607145723.41da5783.davem@redhat.com>
 <20040608210809.GA10542@k3.hellgate.ch> <40C77C70.5070409@tmr.com>
 <20040609213850.GA17243@k3.hellgate.ch> <20040609151246.1c28c4d9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
In-Reply-To: <20040609151246.1c28c4d9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Jun 2004, David S. Miller wrote:

> On Wed, 9 Jun 2004 23:38:50 +0200
> Roger Luethi <rl@hellgate.ch> wrote:
>
> > <sigh> I just killed the module parameters in my via-rhine development
> > tree.
>
> That is absolutely the correct thing to do, module parameters for
> link settings are %100 deprecated, people need to use ethtool for
> everything.

This is precisely the reason why I am concerned about having "rich"
ethtool semantics. A unified, standard interface is great,... as long
it does not leave behind some features, like setting the advertised
values in autoneg. As a user of these features, I hope driver
developers will NOT remove those module_param features that cannot
migrated to ethtool.


On Tue, 8 Jun 2004, Marc Herbert wrote:

> > On Mon, 7 Jun 2004 23:28:04 +0200
> > Roger Luethi <rl@hellgate.ch> wrote:
> >
> > > What is the correct response if a user passes ethtool speed or duplex
> > > arguments while autoneg is on? Some possible answers are:

> > > c) Change advertised value accordingly and initiate new negotiation.

> I find the c) feature very convenient. For instance it allows reliably
> downgrading a link connected to a switch without having to fiddle with
> the configuration of the switch, something which is usually (pick your
> favourites) non-standard, painful, not authorized, not implemented,
> buggy,...

In case any one wondered: probably the most common motivation for
manually downgrading a link is when the cabling is found to be not
"good enough" for the max common speed of the two transceivers.
(see "Gigabit Ethernet - Rich Seifert, section 8.2.3")

See also: "Running 1000BASE-T: Gigabit Ethernet over Copper"
  http://www.10gea.org/GEA_copper_0999_rev-wp.pdf
 "The 1000BASE-T Task Force and the cabling companies estimate that
 less than 10 percent of the installed base of Category 5 cable was
 improperly installed,"

I find "less than 10 percent" not so negligible.
