From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Funny timestamps (Was: Re: rwlock recursion on CPU#0, netfilter related?)
Date: Fri, 30 Sep 2005 09:49:19 +0300
Message-ID: <20050930064919.GA21573@ee.oulu.fi>
References: <20050925105834.GA15243@ee.oulu.fi> <20050925134344.GJ731@sunbeam.de.gnumonks.org> <20050925201945.GA21176@ee.oulu.fi> <20050928145815.GA421@ee.oulu.fi> <20050929120538.GT4168@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050929120538.GT4168@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2005 at 02:05:38PM +0200, Harald Welte wrote:
> > This one is still around, so it's a different bug. Looks like it's a 64-bit
> > issue, a 32-bit ping gives realistic ping times. tcpdump timestamps are also
> > affected, they're completely off too. So looks like someone broke packet
> > timestamps on 64-bit some time after 2.6.13.
> 
> luckily I'm not the core network maintainer ;)
Here's the actual bug report:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=168166

Ended up being a userspace thing, maybe. But still makes me wonder what
change actually broke things. It must have been something soon after 2.6.13.
And there's still tcpdump, which doesn't seem to go into the problem mode
when I test it now, except that nothing should have changed in the
kernel/tcpdump/libpcap versions. Blah.
