From: Jonathan Day <imipak@yahoo.com>
Subject: Re: Automated linux kernel testing results
Date: Fri, 3 Jun 2005 22:01:23 -0700 (PDT)
Message-ID: <20050604050123.9897.qmail@web31504.mail.mud.yahoo.com>
References: <42A0F3B4.1060601@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>, netdev@oss.sgi.com
In-Reply-To: <42A0F3B4.1060601@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am very impressed, especially as it sounds as though
a lot more tests exist (he talks of only pushing small
amounts of data to kernel.org) and a lot more are
going to be added.

It seems to me that there are a lot of disparate test
suites out there - some test the APIs, some benchmark
the performance, some validate the state at the end,
some verify that the source obeys expected rules.

What I have not (yet) seen is any work on relating the
results. Is a bug in the design? The implementation?
Some combination thereof? Is something correctly
written but not functioning because something it
depends on isn't working correctly?

It would even be useful if we could cross-reference
some of the benchmarks with the Linux graphing
project, so that we could see how the complexity of
the tested component differs between versions and
variants. (A small degredation in performance, if
related to a large increase in necessary
sophistication, is not necessarily that bad. The same
performance drop, if related to a massive
simplification of the design, is an indication of a
serious problem.)

Test suites are necessary. Test suites are great.
Anyone working on a test suite deserves many kudos and
much praise. Test suites that are relatable enough
that you can see the same problem from different
angles -- those are worth their printout weight in
gold.

--- Nivedita Singhvi <niv@us.ibm.com> wrote:

> For those who don't read lkml, I thought I'd point
> to
> Martin Bligh's post regarding automated testing
> being
> set up, since some people on this list were
> interested.
> 
>
http://marc.theaimsgroup.com/?l=linux-kernel&m=111775021327595&w=2
> 
> Networking tests are in plan...
> 
> thanks,
> Nivedita
> 
> --------------------------
> 
> OK, I've finally got this to the point where I can
> publish it.
> 
>
http://ftp.kernel.org/pub/linux/kernel/people/mbligh/abat/regression_matrix.html
> 
> 
> Currently it builds and boots any mainline, -mjb,
> -mm kernel within
> about 15 minutes of release. runs dbench, tbench,
> kernbench, reaim and fsx.
> Currently I'm using a 4x AMD64 box, a 16x NUMA-Q, 4x
> NUMA-Q, 32x x440
> (ia32)
> PPC64 Power 5 LPAR, PPC64 Power 4 LPAR, and PPC64
> Power 4 bare metal
> system.
> The config files it uses are linked by the machine
> names in the column
> headers.
> 
> Thanks to all the other IBM people who've worked on
> the ABAT test system
> that this stuff relies on - too many to list, but
> especially Andy, Adam,
> and Enrique, who have fixed endless bugs, and put up
> with my incessant
> bitching about it all not working as it should ;-)
> 
> Clicking on the failure ones error codes should take
> you to somewhere
> vaguely helpful to diagnose it. Clicking on the job
> number just below
> that takes you to the info I'm publishing right now,
> which should
> include perf results and profiles, etc. I'll add
> graphs, etc later,
> comparing performance across kernels (I have them
> ... just not automated).
> 
> 
> 
> 



		
__________________________________ 
Discover Yahoo! 
Find restaurants, movies, travel and more fun for the weekend. Check it out! 
http://discover.yahoo.com/weekend.html 
