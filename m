From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Route cache performance tests
Date: 17 Jun 2003 22:17:14 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1055881034.3199.43.camel@tux.rsn.bth.se>
References: <20030616.160856.35828947.davem@redhat.com>
	 <20030616232750.GD18484@netnation.com>
	 <20030616234937.GE18484@netnation.com>
	 <20030617.085921.28790392.davem@redhat.com>
	 <16111.18107.699689.704597@robur.slu.se>
	 <20030617200721.GA25773@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@redhat.com>, ralph+d@istop.com,
	hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030617200721.GA25773@netnation.com>
List-Id: netdev.vger.kernel.org

On Tue, 2003-06-17 at 22:07, Simon Kirby wrote:

> >  Also think Simon used only /32 routes... I took "real" Internet-routing
> >  and made a script so it can be used for experiments. I can make it available.
> 
> Yes, I found that area less interesting since Dave M. fixed the hash
> buckets.  But yes, the prefix scanning will slow it down some.
> 
> Whoa.  Uhm.  A lot.  I should compare with 2.4 again to see what's going
> on here.

>  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
> 17929        13  214343     0     0     0     0 163822         0       0      0   50521   50519         0    0

Did you have rp_filter enabled? Looks like it.

-- 
/Martin
