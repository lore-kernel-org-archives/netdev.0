From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [2/2] 2.6.22-rc4: known regressions v3
Date: Thu, 14 Jun 2007 11:30:25 +0100 (BST)
Message-ID: <Pine.LNX.4.61.0706141123160.28903@mtfhpc.demon.co.uk>
References: <46704923.1010009@googlemail.com> <46704C44.8020602@googlemail.com>
 <Pine.LNX.4.61.0706132320200.26751@mtfhpc.demon.co.uk>
 <20070614020055.GL15426@holomorphy.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
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
To: William Lee Irwin III <wli@holomorphy.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20070614020055.GL15426@holomorphy.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

They apear as soon as simpleinit starts up. Somtimes I get to a login 
prompt before seeing any. Other times, commands in the simpleinit rc 
script fail.

They do apear to be random. If a command failes, you re-run the command 
and it is OK. Commands seen to fail are basic (depmod, rm cat ..).

The test I did use the same binaries with both the OK and problem kernels 
so it is not a change to the application code, it is definatly a kernel 
issue.

Regards
 	Mark Fortescue.

On Wed, 13 Jun 2007, William Lee Irwin III wrote:

> On Wed, Jun 13, 2007 at 11:25:20PM +0100, Mark Fortescue wrote:
>> The random seg faults on x86_64 is interesting as I have been getting
>> random illegal instruction faults on sparc (sun4c) with 2.6.22-rc3. I have
>> not yet tried to track it down. All I know at present is that it is not a
>> problem on 2.6.20.9.
>
> Very interesting. Any hints as to how to test or how long to wait
> before the illegal instructions happen?
>
>
> -- wli
>
