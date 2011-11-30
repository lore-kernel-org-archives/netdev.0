From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: Integration of Open vSwitch
Date: Wed, 30 Nov 2011 08:11:56 -0500
Message-ID: <1322658716.2243.12.camel@mojatatu>
References: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-11-29 at 22:25 -0800, Jesse Gross wrote:
> Hi Herbert and Jamal (and everyone else),
> 
> Sorry about starting yet another thread but the other one went in so
> many directions that I think a lot of things got lost in it.  

Good idea ;->

> As I
> mentioned before, I'd like to have a bit of a design discussion of
> what it would look like if Open vSwitch were to use some of the
> existing components (and really focus on just that).  There were a
> number of suggestions made about using parts of the bridge, tc,
> netfilter, etc. and some of them overlap or conflict so I don't quite
> have a coherent solution in mind.  Would you guys mind walking through
> what each of you envision it looking like?

I'll try my TL;DR version:
My opinion is the classifier action code needs refactoring. I have no
doubt that it goes in as is it will eventually look like the one
we already have. From the evolution of that code i can already see 
that is where it is going. I really dont see need to have two competing
interfaces in that aspect. If you decide to go that way I will be
happy to help review and make suggestions.

My !TL;DR version will include details on other things like:
- bridging, the scalability of kernel->user packet redirect etc.
But youve seen some of those views.

cheers,
jamal
