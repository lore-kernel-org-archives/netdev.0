From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: Please route new work through -mm tree?
Date: Wed, 29 Sep 2004 14:12:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CClkI-0001m2-00@w-gerrit.beaverton.ibm.com>
References: <20040929132247.227fffcd.davem@davemloft.net>
Reply-To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Nivedita Singhvi <niv@us.ibm.com>, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-reply-to: Your message of Wed, 29 Sep 2004 13:22:47 PDT.
             <20040929132247.227fffcd.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 29 Sep 2004 13:22:47 PDT, "David S. Miller" wrote:
> On Wed, 29 Sep 2004 11:13:55 -0700
> Nivedita Singhvi <niv@us.ibm.com> wrote:
> 
> > I was going to suggest a separate bk tree or something that would
> > hold this stuff till it stabilized, before it needed
> > to go into mainline.
> 
> Nivedita, it was you specifically who complained to me
> when I used a seperate BK tree for networking changes
> last month whilst Linus was away for 2 weeks.  You said
> that this gave IBM too many trees to work from, so I told
> you that what I was doing was a temporary thing until Linus
> came back from his trip.
> 
> Now you're suggesting that I specifically do what you asked
> me not to do a month ago.
> 
> So figure out what you really want.
> 
> And I have to warn people if they think that the churn is fast
> and the rate of change in the networking is high right now, you
> have seen absolutely nothing yet. :-)

Hi Dave, having a bk tree which akpm can merge into his would
mean that all of our standard testing would get run over networking
changes as well as everything else.  We typically run some pretty
exhaustive tests on a small number of trees.  We try to focus on
-rc trees from Linus and the -mm trees.  As a result, networking
testing (by us) is done really late in the cycle compared to your
rate of change in pushing to Linus.

So, ideally, if you had your own tree published in such a way
that akpm could pull in, we'd probably have the best of all
worlds.

gerrit
