From: "Filip Sneppe (Cronos)" <filip.sneppe@cronos.be>
Subject: Re: TODO list before feature freeze
Date: 30 Jul 2002 17:54:20 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1028044460.381.127.camel@xbox>
References: <Pine.GSO.4.30.0207300818480.15727-100000@shell.cyberus.ca>
	<1028034504.12617.135.camel@tux>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Patrick Schaaf <bof@bof.de>,
   Andi Kleen
	 <ak@suse.de>, Rusty Russell <rusty@rustcorp.com.au>,
   Netfilter-devel
	 <netfilter-devel@lists.netfilter.org>, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1028034504.12617.135.camel@tux>
List-Id: netdev.vger.kernel.org

On Tue, 2002-07-30 at 15:08, Martin Josefsson wrote:
> On Tue, 2002-07-30 at 14:29, jamal wrote:
> 
> > If i was to use instinct i would say
> > the last two items you list are probably the things you may want to chase.
> 
> Here's two small patches.
> 
> The first is a small patch to avoid updating the per-connection timer
> for every packet. With this patch you get one update per second per
> connection. Things are complicated by the fact that connections can
> change timeouts. This patch isn't verified for correctness, YMMV.
> (the pptp helper needs updating to work in combination with this patch)
> 
> The second patch changes the hashtable lookup slightly so we don't hash
> the tuple each iteration, once is enough.
> 
> I don't have any numbers for these patches and I can't find the url to
> the tests one of the netfilter-devel people has done.
> 

Hi Martin,

These may be the patches I did some very basic testing (and readprofile
profiling) on.

http://www.filip.sneppe.yucom.be/linux/netfilter/performance/benchmarks.htm

I don't have a lot to add to the discussion except that I can make time
to test patches/ideas provided someone tells me *how* to test, what to
look for, etc. For instance, a lot of the current numbers on that page
with the varying mtu sizes are, in retrospect, basically stupid tests
that don't reveal a lot of new stuff :-/.

Regards,
Filip

Regards,
Filip
