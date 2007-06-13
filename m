From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [2/2] 2.6.22-rc4: known regressions v3
Date: Wed, 13 Jun 2007 23:25:20 +0100 (BST)
Message-ID: <Pine.LNX.4.61.0706132320200.26751@mtfhpc.demon.co.uk>
References: <46704923.1010009@googlemail.com> <46704C44.8020602@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
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
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <46704C44.8020602@googlemail.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

The random seg faults on x86_64 is interesting as I have been getting 
random illegal instruction faults on sparc (sun4c) with 2.6.22-rc3. I have 
not yet tried to track it down. All I know at present is that it is not a 
problem on 2.6.20.9.

Regards
 	Mark Fortescue.

On Wed, 13 Jun 2007, Michal Piotrowski wrote:

> Hi all,
>
> Here is a list of some known regressions in 2.6.22-rc4.
>
> Feel free to add new regressions/remove fixed etc.
> http://kernelnewbies.org/known_regressions
>
>
>
> Networking
>
> Subject    : commit 9093bbb2d96d0184f037cea9b4e952a44ebe7c32 broke the 
> bonding driver
> References : http://lkml.org/lkml/2007/6/13/65
> Submitter  : Dan Aloni <da-x@monatomic.org>
> Handled-By : Stephen Hemminger <shemminger@linux-foundation.org>
> Status     : Unknown
>
>
>
> Sparc64
>
> Subject    : 2.6.22-rc broke X on Ultra5
> References : http://lkml.org/lkml/2007/5/22/78
> Submitter  : Mikael Pettersson <mikpe@it.uu.se>
> Handled-By : David Miller <davem@davemloft.net>
> Status     : problem is being debugged
>
>
>
> Suspend
>
> Subject    : hibernate(?) fails totally - regression
> References : http://lkml.org/lkml/2007/6/1/401
> Submitter  : David Greaves <david@dgreaves.com>
> Handled-By : Rafael J. Wysocki <rjw@sisk.pl>
> Caused-By  : Tejun Heo <htejun@gmail.com>
>            commit 9666f4009c22f6520ac3fb8a19c9e32ab973e828
> Status     : problem is being debugged
>
>
>
> TTY
>
> Subject    : OOPS (NULL pointer dereference) in v2.6.22-rc3
> References : http://lkml.org/lkml/2007/6/1/389
>            http://bugzilla.kernel.org/show_bug.cgi?id=8473
>            http://bugzilla.kernel.org/show_bug.cgi?id=8574
> Submitter  : Alex Riesen <raa.lkml@gmail.com>
> Status     : problem is being debugged
>
>
>
> x86-64
>
> Subject    : x86-64 2.6.22-rc2 random segfaults
> References : http://lkml.org/lkml/2007/5/24/275
> Submitter  : Ioan Ionita <opslynx@gmail.com>
> Status     : Unknown
>
>
>
> Regards,
> Michal
>
> -- 
> LOG
> http://www.stardust.webpages.pl/log/
> -
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
