From: "Natalie Protasevich" <protasnb@gmail.com>
Subject: Open bugs
Date: Tue, 12 Feb 2008 00:18:49 -0800
Message-ID: <32209efe0802120018r17c38835ud931085e44aafefb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-ide@vger.kernel.org, bugme-daemon@kernel-bugs.osdl.org
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The bugs listed are over a month old, and haven't been addressed yet.
It would be appreciated if corresponding maintainers identify whether
the bugs have been fixed, or need to be worked on, and take
appropriate action.

In most cases, reporters are standing by and ready to provide
information and necessary testing.
Thanks!


Memory Management=======================================

swapping in 2.6.24-rc5-git3
http://bugzilla.kernel.org/show_bug.cgi?id=9592
Date: 12/07/2007
Regression
Summary:
# /proc/sys/vm# cat swappiness
0
but scp-ing 2GB file causes many processes are swapped out due to
increase of the file cache size.
Was looked at by Jan Kara <jack@suse.cz>; KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> - commented


I/O-Storage================================================

SATA DVD drive & UDF filesystem problem
http://bugzilla.kernel.org/show_bug.cgi?id=9668
12/31/2007
Summary: I mount dvd discs (udf) with piix and ide_cd modules without
problem (on hw decribed higher).
Then I put NEC drive to new mainboard (ICH9 + jmicron SATA/PATA chips)
and use ahci (jmicron) + sr_mod modules.


SCSI======================================================

Problems on booting
http://bugzilla.kernel.org/show_bug.cgi?id=9621
Date: 12/22/2007
Regression
Summary: The boot stops / hangs on hardware detection of SCSI.  I have
an InitioINI-9X00U/UW
When I have an usb key sticked in /dev/sba, and run lilo then, then it
dont boot but give L99 99 99 99 ... error


Resetting RAID attached to a FC Switch causes kernel panic and crash
http://bugzilla.kernel.org/show_bug.cgi?id=9598
12/18/2007
Hardware Environment:SunFire X4200 - 2 x dual core AMD Opteron CPUs,
8GB Ram, Qlogic FC adapter.
Summary: Resetting the RAID box causes the X4200 to crash.

3ware 9650SE -8LPML not recognized by 3w-9xxx driver
http://bugzilla.kernel.org/show_bug.cgi?id=8908
08/19/2007
Problem Description: The 3w-9xxx kernel driver for 3ware 9xxx SATA
RAID Controller series did not recognize the 3ware 9650SE-8LPML SATA
RAID Controller.


Plarform===================================================

kexec buffer error
http://bugzilla.kernel.org/show_bug.cgi?id=9693
Date: 01/04/2008
Regression
Summary: Close of /boot/kernel-2.6.24-rc6-git11 failed: : buffer error
kexec load failed, error = 1


20000+ wake-ups/second in 2.6.24
http://bugzilla.kernel.org/show_bug.cgi?id=9489
Date: 12/02/2007
Summary: "something" is causing the system to go into a state where
the cpu throws us right out of the C-state the kernel asks for
Discussed: Arjan van de Ven, Mark Lord


VIDEO/FB======================================================

No text consoles with FRAMEBUFFER_CONSOLE_DETECT_PRIMARY
http://bugzilla.kernel.org/show_bug.cgi?id=9310
11/05/2007 still there
Regression
Summary: After initial boot messages all output to console stops. The
last visible messages are:
checking if image is initramfs...<6>Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 0
After that, nothing until XOrg starts up and graphical login/desktop
on VT7are displayed normal.


DVB===========================================================

DVB-T Pluto2: SUSPEND/RESUME methods are missing for this driver
04/05/2007 - still present in 2.6.24
http://bugzilla.kernel.org/show_bug.cgi?id=8304
Summary: After SWSUPS resume, pluto2 card is not started properly, led
getts not green and card is unable load tda firmware
Hardware Environment: Acer TravelMate
No one looked at it yet.

Several Pluto bug:

DVB-T Pluto2 && PCI: When playing in dmesg I often getts: "pluto2
0000:03:00.0: overflow irq (10)"
Date: 11/08/2006 still there
http://bugzilla.kernel.org/show_bug.cgi?id=7473
Hardware Environment: Acer TravelMate


DVB-T Pluto2: Getting tons of "card hung up :(" messages when card is
removed from pcmcia slot
Date: 11/08/2006 - still there
http://bugzilla.kernel.org/show_bug.cgi?id=7472


DVB-T Pluto2: Unable to change MUX
Date: 11/08/2006
http://bugzilla.kernel.org/show_bug.cgi?id=7471


KNC1 DVB-C cam module not working on driver load
Date: 1/15/2007 - still there
http://bugzilla.kernel.org/show_bug.cgi?id=7825
Error:
DVB: registering new adapter (KNC1 DVB-C)
adapter failed MAC signature check
encoded MAC from EEPROM was
ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff
KNC1-0: MAC addr = 00:09:d6:6d:5a:f0
TDA10021: i2c-addr = 0x0c, id = 0x7c
DVB: registering frontend 0 (Philips TDA10021 DVB-C)...
budget-av: ci interface initialised.
budget-av: cam inserted A
dvb_ca adaptor 0: PC card did not respond :(


build #341 failed for 2.6.24-rc6-g1842c7f in
linux/./drivers/media/dvb/ttpci/budget-av.c
01/01/2008
http://bugzilla.kernel.org/show_bug.cgi?id=9671
Still there in 2.6.24.. has it been fixed?


DVB-USB UMT-010 driver has certain oops when installed
01/09/2008
http://bugzilla.kernel.org/show_bug.cgi?id=9720
In the umt-010 driver the struct umt_properties sets the number of
URBs for transfer to 20.
But in dvb-usb.h MAX_NO_URBS_FOR_DATA_STREAM is set to 10. This causes
an oops for all devices which use the umt-010 chipset when they are
inserted.


v4l Problem with dvb-usb and Hauppage USB Stick
http://bugzilla.kernel.org/show_bug.cgi?id=9001
9/9/2007
x86_64
dvb-usb: Hauppauge Nova-T Stick crashes during channel search with Kaffeine


KEXEC=============================================================

kexec buffer error
http://bugzilla.kernel.org/show_bug.cgi?id=9693
01/05/2008
2.6.24-rc6-git9 works as expected.  git10 fails with root device not found


DRIVERS===========================================================

Two small bugs detected by code review:

physmap does not have a release() function
01/05/2008
http://bugzilla.kernel.org/show_bug.cgi?id=9690
Summary: Pretty trivial addition of the release()

hgafb module is broken & unmaintained
http://bugzilla.kernel.org/show_bug.cgi?id=9689
This one also needs release() function


FILESYSTEMS======================================================

journal_data mount option causes filesystem corruption with blocksize != 4096
01/05/2008
http://bugzilla.kernel.org/show_bug.cgi?id=9692
Appears to be e2fsck problem


ALSA==============================================================

SC-5200 + wine = System freeze
http://bugzilla.kernel.org/show_bug.cgi?id=9649
12/27/2007
-- Motherboard: Asus A8R-MVP
-- Harddrive: Samsung 200Gb
-- Soundcard 1: Onboard
-- Soundcard 2: Trust SC-5200
Running any part of wine freezes up the whole system. Both SSH
connections, the normal X screen and any other device, including sound
played by for example music players, freezes up. After about 10
seconds the system reboots.
By removing my second sound card it works. By disabling my onboard
sound it still causes the freeze.


Networking=========================================================

An ioctl to delete an ipv6 tunnel leads to a kernel panic
http://bugzilla.kernel.org/show_bug.cgi?id=8895
8/16/2007
Summary: The mip6d HA was modified to make a redundancy evolution,
when an HA is interrupted, the other takes over, this leads to some
creation/deletion of routes and tunnels.


BUG: bad unlock balance detected!
http://bugzilla.kernel.org/show_bug.cgi?id=9542
Date: 12/11/2007
Summary:
...bug in the bonding driver...bond->lock should always turn BH off,
even on read lock.
Handled: Herbert Xu
Problem and solution has been identified, but the bug stalled -
probably needs someone to submit an actual patch


WIRELESS==========================================================

IWL3945 generates WARNING in mac80211/rx.c code
http://bugzilla.kernel.org/show_bug.cgi?id=9656
12/28/2007
WARNING: at net/mac80211/rx.c:1486 __ieee80211_rx()
Pid: 0, comm: swapper Not tainted 2.6.24-rc6 #8
Call Trace:
 <IRQ>  [<ffffffff88123d89>] :mac80211:__ieee80211_rx+0xc69/0xd30
 [<ffffffff812abd86>] _spin_lock_irqsave+0x26/0xa0
 [<ffffffff812ac3a5>] _spin_unlock_irqrestore+0x15/0x30
 [<ffffffff8815af91>] :iwl3945:iwl_rx_queue_restock+0xd1/0x160
 [<ffffffff812abd86>] _spin_lock_irqsave+0x26/0xa0
 [<ffffffff88114f7b>] :mac80211:ieee80211_tasklet_handler+0xbb/0x120
 [<ffffffff810420a7>] tasklet_action+0x47/0xb0
 [<ffffffff81041fb9>] __do_softirq+0x59/0xd0
 [<ffffffff8100d5dc>] call_softirq+0x1c/0x30
 [<ffffffff8100f975>] do_softirq+0x35/0x90
 [<ffffffff81041ee5>] irq_exit+0x85/0x90
 [<ffffffff8100fa54>] do_IRQ+0x84/0x100
 [<ffffffff8100c931>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff811a312f>] acpi_idle_enter_bm+0x272/0x2de
 [<ffffffff811a3125>] acpi_idle_enter_bm+0x268/0x2de
 [<ffffffff81230357>] cpuidle_idle_call+0x97/0xd0
 [<ffffffff812302c0>] cpuidle_idle_call+0x0/0xd0
 [<ffffffff8100b001>] cpu_idle+0x71/0xe0


 NFS/RPC===================================================

 in-kernel rpc generates broken RPCBPROC_GETVERSADDR v4 requests
 http://bugzilla.kernel.org/show_bug.cgi?id=8891
 8/15/2007
 Problem Description: When locking a file, an invalid
RPCBPROC_GETVERSADDR procedure call is sent out
 Chuck Lever looked at it a while ago
