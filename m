From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Question about QOS
Date: Tue, 3 May 2005 14:40:32 -0700
Message-ID: <20050503144032.25ea921d.davem@davemloft.net>
References: <426E06F1.9000105@6wind.com>
	<20050426125955.GT577@postel.suug.ch>
	<426E56DC.7000108@6wind.com>
	<20050426191454.GU577@postel.suug.ch>
	<426F42F0.9020609@6wind.com>
	<20050427114216.GV577@postel.suug.ch>
	<427225B2.6010705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, nicolas.dichtel@6wind.com, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427225B2.6010705@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Apr 2005 14:16:50 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Thomas Graf wrote:
> > * Nicolas DICHTEL <426F42F0.9020609@6wind.com> 2005-04-27 09:44
> > 
> >>>Yes I agree, it doesn't really matter what value we return and `bound'
> >>>is most likely to be correct. I think we should also fix the unlikely
> >>>but still possible case when tv1.tv_usec is slightly smaller than
> >>>tv2.tv_usec. I know it is very unlikely but do_gettimeofday really
> >>>is not that reliable and we have users which rely on a positive
> >>>delta. Can you extend your patch to return abs(delta) for case 0
> >>>in PSCHED_TDIFF_SAFE?
> 
> Why abs(delta)? It could be above bound, in fact all cases besides
> delta_sec > 2 doesn't take care to stay inside [0..bound] at all.

Applied, thanks Patrick.
