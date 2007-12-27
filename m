From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Thu, 27 Dec 2007 21:41:45 +0300
Message-ID: <20071227184145.GA1831@martell.zuzino.mipt.ru>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org> <m1hcj8mz1p.fsf_-_@ebiederm.dsl.xmission.com> <1197003097.13978.557.camel@pmac.infradead.org> <20071207022342.806ee4ee.akpm@linux-foundation.org> <20071227174056.GA17350@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754283AbXL0SmR@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071227174056.GA17350@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 27, 2007 at 06:40:56PM +0100, Andreas Mohr wrote:
> On Fri, Dec 07, 2007 at 02:23:42AM -0800, Andrew Morton wrote:
> > > (commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416)
> > > 
> > > This seems to have broken the use of /proc/bus/usb as a mountpoint. It
> > > always appears empty now, whatever's supposed to be mounted there.
> > > 
> > 
> > Yes.  Denis and Eric are tossing around competing patches but afaik nobody
> > is happy with any of them.  Guys, could we get this sorted soonish please?
> 
> "Soonish" being rather earlier than 20071227?
> 'cause it's still throwing a fit for me on 2.6.24-rc6-mm1(!) (plus hotfix),
> nothing visible in /proc/bus/usb, thus WLAN driver won't probe
> anything.

Patch which restores usual behaviour was merged in 2.6.24-rc5
(3790ee4bd86396558eedd86faac1052cb782e4e1 "proc: remove/Fix proc generic d_revalidate")
so no hotfixes are needed. I just checked with bind mounting / to
/proc/bus/usb -- it works.
