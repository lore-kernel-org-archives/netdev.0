From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [2/2] 2.6.22-rc4: known regressions v3
Date: Thu, 14 Jun 2007 07:21:46 -0700
Message-ID: <20070614142146.GN15426@holomorphy.com>
References: <46704923.1010009@googlemail.com> <46704C44.8020602@googlemail.com> <Pine.LNX.4.61.0706132320200.26751@mtfhpc.demon.co.uk> <20070614020055.GL15426@holomorphy.com> <Pine.LNX.4.61.0706141123160.28903@mtfhpc.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Dan Aloni <da-x@monatomic.org>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mikael Pettersson <mikpe@it.uu.se>,
	linux-pm@lists.linux-foundation.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	linux-usb-devel@lists.sourceforge.net,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Alex Riesen <raa.lkml@gmail.com>, Andi Kleen <ak@suse.de>,
	discuss@x86-64.org, Ioan Ionita <opslynx@gmail.com>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0706141123160.28903@mtfhpc.demon.co.uk>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 14, 2007 at 11:30:25AM +0100, Mark Fortescue wrote:
> They apear as soon as simpleinit starts up. Somtimes I get to a login 
> prompt before seeing any. Other times, commands in the simpleinit rc 
> script fail.
> They do apear to be random. If a command failes, you re-run the command 
> and it is OK. Commands seen to fail are basic (depmod, rm cat ..).
> The test I did use the same binaries with both the OK and problem kernels 
> so it is not a change to the application code, it is definatly a kernel 
> issue.

This sounds like it may be addressed by benh's ptep_set_access_flags()
fixes. Those fixes are still in -mm, hopefully to hit mainline by 2.6.22.


-- wli
