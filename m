From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Question about QOS
Date: Thu, 28 Apr 2005 12:14:44 -0700
Message-ID: <20050428121444.3d42fcfa.davem@davemloft.net>
References: <426E06F1.9000105@6wind.com>
	<20050426125955.GT577@postel.suug.ch>
	<426E56DC.7000108@6wind.com>
	<20050426191454.GU577@postel.suug.ch>
	<426F42F0.9020609@6wind.com>
	<20050427114216.GV577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050427114216.GV577@postel.suug.ch>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Apr 2005 13:42:16 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * Nicolas DICHTEL <426F42F0.9020609@6wind.com> 2005-04-27 09:44
> > 
> > >Yes I agree, it doesn't really matter what value we return and `bound'
> > >is most likely to be correct. I think we should also fix the unlikely
> > >but still possible case when tv1.tv_usec is slightly smaller than
> > >tv2.tv_usec. I know it is very unlikely but do_gettimeofday really
> > >is not that reliable and we have users which rely on a positive
> > >delta. Can you extend your patch to return abs(delta) for case 0
> > >in PSCHED_TDIFF_SAFE?
> > >
> > You're right. Here is the new patch.
> > 
> > [SCHED] Fix range in PSCHED_TDIFF_SAFE to 0..bound
> > 
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks everyone.
