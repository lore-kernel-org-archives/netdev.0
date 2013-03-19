From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: Re: [BUG][mvebu] mvneta: cannot request irq 25 on
 openblocks-ax3
Date: Tue, 19 Mar 2013 10:33:04 -0400
Message-ID: <20130319143304.GT13280@titan.lakedaemon.net>
References: <51486445.8040506@hitachi.com>
 <20130319133324.GS13280@titan.lakedaemon.net>
 <514873D9.6060704@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <514873D9.6060704@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 19, 2013 at 11:19:05PM +0900, Masami Hiramatsu wrote:
> Hi Jason,
> 
> (2013/03/19 22:33), Jason Cooper wrote:
> > On Tue, Mar 19, 2013 at 10:12:37PM +0900, Masami Hiramatsu wrote:
> >> Hi,
> >>
> >> Here I've hit a bug on the recent kernel. As far as I know, this bug
> >> exists on 3.9-rc1 too.
> >>
> >> When I tried the latest mvebu for-next tree
> >> (git://git.infradead.org/users/jcooper/linux.git mvebu/for-next),
> > 
> > FYI: that branch isn't stable, it's used as a merge-test of
> > arm-soc/for-next (also not stable) and any branches I am trying to push
> > upstream that day.
> 
> Thanks! could you tell me which branch is stable?
> (however, I'd like to try new fixes/features on my device too :))

Generally, we advise using one of Linus' tags (eg v3.9-rc3).  Only if
that doesn't work, seek out a branch containing the fix/feature.  When
in doubt, I'll do:

$ ./scripts/get_maintainer.pl -f drivers/net/ethernet/marvell/mvneta.c

and ask those listed which branch might contain a fix or feature.

In this case, it'll probably go through David Miller and the netdev
mailinglist, but it isn't there yet.  ;-)

hth,

Jason.
