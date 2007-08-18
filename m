From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] i386: optimize memset of 6 and 8 bytes
Date: Fri, 17 Aug 2007 20:31:39 -0700
Message-ID: <20070817203139.61d1505b@freepuppy.rosehill.hemminger.net>
References: <20070817165030.5455f761@freepuppy.rosehill.hemminger.net>
	<1187401774.2789.0.camel@laptopd505.fenrus.org>
	<20070817185452.5cbf60c4@freepuppy.rosehill.hemminger.net>
	<1187402220.2789.2.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755301AbXHRDcI@vger.kernel.org>
In-Reply-To: <1187402220.2789.2.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007 18:57:00 -0700
Arjan van de Ven <arjan@infradead.org> wrote:

> 
> On Fri, 2007-08-17 at 18:54 -0700, Stephen Hemminger wrote:
> > On Fri, 17 Aug 2007 18:49:34 -0700
> > Arjan van de Ven <arjan@infradead.org> wrote:
> > 
> > > 
> > > On Fri, 2007-08-17 at 16:50 -0700, Stephen Hemminger wrote:
> > > > Tne network code does memset for 6 and 8 byte values, that can easily
> > > > be optimized into simple assignments without string instructions.
> > > 
> > > 
> > > so... question.
> > > Why are we doing this by hand? Wouldn't gcc just generate this code in
> > > the first place (when using __builtin_memset)? I very much suspect it
> > > would (and if some version doesn't.... we really ought to get that
> > > fixed)
> > 
> > i386 and x86_64 are not using __builtin_memset, as least from the
> > code that I see generated.
> 
> .. maybe we should just fix it that way then?
> 
There probably is history behind the decision, like gcc problems
on some old compiler version.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
