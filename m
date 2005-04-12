From: "Shaun Reitan" <mailinglists@unix-scripts.com>
Subject: Kernel Panic - not syncing: Fatal Exception in interupt.
Date: Tue, 12 Apr 2005 12:27:47 -0700
Message-ID: <027301c53f95$b72bdfb0$0201a8c0@ndciwkst01>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is my original post to the linux.kernel mailing lists regarding this
problem....

-------------------------------[ORIGINAL POST]-----------------
+Hardware Specs
Dual Xeon 800FSB
Intel Server Board
4GB ECC DDR
3ware 9500 Sata Raid Card
5x200 GB sata drives in a raid 10 Config (1 hot spare)
Dual Nic

+OS Specs
CentOS 3.4 running a custom 2.6.x kernel patched with UML SKA's Patch
eth0 is 0.0.0.0 promisc and assigned to a bridge (br0)
tuntap devices up
ebtables is enabled and loaded with rules

My problem is that every other week or so the machine crashes.  It never
dumps the error to the logs so all i have is a screen shot of the console.
I have put some serious stress on this machine and have been unable to
duplicate the problem (running 20 guest UML's half running va-ctcs and
the other half compiling a 2.6 kernel).   Below is a link to 2 screen shots
i have (about 2 weeks apart).  I started off using a 2.6.10 kernel when
the problem started.  Last time the machine crashed i built a 2.6.11.5
kernel and disabled APM and ACPI in the kernel config.  Any body know whats
going on here.

http://www.unix-scripts.com/shaun/host-screenshot-1.png
http://www.unix-scripts.com/shaun/host-screenshot-2.png

Kernel Config... http://www.unix-scripts.com/shaun/2.6.11.5-hr1_.config
----------------------------------------------------------------------------
--------

Since then the machine has crashed 2 more times but this time the crashes
where only a few hours appart.  I changed the resolution on the console to
791 so i was able to catch alittle more of the dump.  I enabled console
serial redirection in the BIOS so i'm hopping i'm going to be able to catch
a full dump the next time this happens.  Here are a few more screen shots
and the link to the kernel post i have going.

The first screen shot is with the old resolution so didnt catch much more
here...
http://www.unix-scripts.com/shaun/host1-2005-04-12-01.png

But this screen shot got a nice chunk and looks a bit diffrent.
http://www.unix-scripts.com/shaun/host1-2005-04-12-02.png

http://thread.gmane.org/gmane.linux.kernel/293810


Thanks in advance!

Shaun Reitan
