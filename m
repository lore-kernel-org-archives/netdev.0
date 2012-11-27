From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Tue, 27 Nov 2012 19:39:37 +0100
Message-ID: <20121127183937.GA1105@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354039349.2534.11.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2012 at 06:02:29PM +0000, David Woodhouse wrote:
> 
> I'm not running with that patch. This bug exists for br2684 even before
> it, and I think also for pppoatm.
> 

Did you use your "atm: br2684: Fix excessive queue bloat" patch?

With that patch for pppoatm the dev->close()/pppoatm_send() race
was much easier to trigger. Maybe with an equivalent patch for br2684
the races are also easier triggerable.

Krzysiek
