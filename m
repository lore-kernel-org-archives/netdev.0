From: Ross Combs <rocombs@cs.nmsu.edu>
Subject: Small 2.6.11.8 airo.c issue
Date: Fri, 06 May 2005 23:10:37 -0500
Message-ID: <427C3FBD.mailOLE1FRMAW@hongkong>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: achirica@ttd.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I ran into a small configuration problem a couple of days ago while
using menuconfig to setup a new kernel for my laptop.  Basically,
it refused to show the airo.c driver as an option.  After looking
at the Kconfig files I figured out it was because I did not have ISA
enabled -- but I'm not using an ISA version of the card so it should
not be a dependency.

I originally reported it to Jean Tourrilhes but he said that netdev
would be a better place to send it and that Javier might know why it
was added.  My original message is included below.


> I just upgraded my system to a recent 2.6 kernel and noticed a small
> bug in the configuration for the airo.c driver.  It now requires
> that ISA be enabled, though it is not a requirement for all hardware
> using that driver.  In my case, I'm using an IBM T30 laptop with a
> mini-PCI card.
>
> Once I edited the Kconfig file to remove the ISA dependency (maybe it
> should be an OR instead of an AND but removing it was easier for a
> local change), I was able to select the driver.  It compiled without
> problems and I'm using it successfully with encryption for the first
> time ever.
>
> I'm very happy with the new driver.
>
> Please let me know if this is not the right place to report bugs.  I
> just mailed the people listed in the source code.

Thanks,
-Ross
