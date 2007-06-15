From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [2/2] 2.6.22-rc4: known regressions v3
Date: Fri, 15 Jun 2007 16:26:09 -0700 (PDT)
Message-ID: <alpine.LFD.0.98.0706151624340.14121@woody.linux-foundation.org>
References: <46704923.1010009@googlemail.com>
 <46704C44.8020602@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <46704C44.8020602@googlemail.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 13 Jun 2007, Michal Piotrowski wrote:
> 
> Subject    : hibernate(?) fails totally - regression
> References : http://lkml.org/lkml/2007/6/1/401
> Submitter  : David Greaves <david@dgreaves.com>
> Handled-By : Rafael J. Wysocki <rjw@sisk.pl>
> Caused-By  : Tejun Heo <htejun@gmail.com>
>             commit 9666f4009c22f6520ac3fb8a19c9e32ab973e828
> Status     : problem is being debugged

Ahh. This is fixed (fix by Tejun, confirmed by David), and the fix has 
been merged. It's commit bc90ba093a, in case anybody cares.

		Linus
