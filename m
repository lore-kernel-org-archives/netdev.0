From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 08:43:29 +0100
Message-ID: <20080414074329.GY9785@ZenIV.linux.org.uk>
References: <20080413121831.d89dd424.akpm@linux-foundation.org> <20080413202118.GA29658@2ka.mipt.ru> <200804132233.50491.rjw@sisk.pl> <20080413205406.GA9190@2ka.mipt.ru> <48028830.6020703@earthlink.net> <alpine.DEB.1.10.0804131546370.9318@asgard> <20080414043939.GA6862@1wt.eu> <20080414053943.GU9785@ZenIV.linux.org.uk> <20080413232441.e216a02c.akpm@linux-foundation.org> <20080414072328.GW9785@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, david@lang.hm,
	Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <git-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080414072328.GW9785@ZenIV.linux.org.uk>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2008 at 08:23:28AM +0100, Al Viro wrote:

> And the latter part _must_ be done on each entry point.  Any git tree
> that acts as injection point really needs a working mechanism of some
> sort that would do that; afterwards it's too late, since review of
> the stuff getting into mainline on a massive merge is sadly impractical.

PS: net/* is actually pretty sane in that respect - the huge volume
being what it is, of course, but still, my impression is that it's
pretty far from the worst sources of crap.  OTOH, I might be missing
secondary tree problems - e.g. net/sctp is much worse off in that
respect, AFAICT; there might very well be more of such areas.
