From: "Shawn Starr" <shawn.starr@rogers.com>
Subject: RE: [BUG][2.6.5 final][e100/ee100pro] NETDEV_WATCHDOG Timeout -Related to i2c interface?
Date: Sun, 11 Apr 2004 16:09:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000001c42000$dd6e78f0$0200080a@panic>
References: <1081671742.2844.0.camel@dhcppc4>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Len Brown'" <len.brown@intel.com>
In-Reply-To: <1081671742.2844.0.camel@dhcppc4>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok, this is strange, I put in an external 10/100 PRO S Adaptor, and im not
getting anymore eth0 timeouts, I would only get eth0 timeouts on the ONBOARD
nic if I enabled the lm80 sensor driver.. I don't know what to say, the
onboard nic would work fine without lm80 being loaded?

Is there some sort of race condition that the onboard 10/100 PRO is doing ?

I'm confused

-----Original Message-----
From: Len Brown [mailto:len.brown@intel.com] 
Sent: Sunday, April 11, 2004 04:22 AM
To: Shawn Starr
Subject: RE: [BUG][2.6.5 final][e100/ee100pro] NETDEV_WATCHDOG Timeout
-Related to i2c interface?


it could be that i2c is hooked up to the NIC for some management purpose --
maybe Scott knows.

On Sun, 2004-04-11 at 03:32, Shawn Starr wrote:
> No, something else is causing problem, don't know why i2c is?
> 
> -----Original Message-----
> From: Brown, Len [mailto:len.brown@intel.com]
> Sent: Sunday, April 11, 2004 01:22 AM
> To: Shawn Starr
> Subject: RE: [BUG][2.6.5 final][e100/ee100pro] NETDEV_WATCHDOG Timeout -
> Related to i2c interface?
> 
> 
> So ACPI enabled/disabled doesn't make any difference?
> 
> >-----Original Message-----
> >From: Shawn Starr [mailto:shawn.starr@rogers.com]
> >Sent: Saturday, April 10, 2004 2:23 AM
> >To: Feldman, Scott; Brown, Len
> >Cc: linux-kernel@vger.kernel.org; netdev@oss.sgi.com
> >Subject: [BUG][2.6.5 final][e100/ee100pro] NETDEV_WATCHDOG
> >Timeout - Related to i2c interface?
> >
> >
> >Ok, did disable ACPI but still get these errors. I have noticed that 
> >if I start loading/unloading any i2c drivers I start getting eth0
> >timeouts....the
> >question is why?
> >
> >coredump kernel: i2c_adapter i2c-2: Transaction (post): CNT=08, 
> >CMD=3a,
> >ADD=50, DAT0=3e, DAT1=00 Apr 10 01:56:44 coredump kernel: i2c-core: 
> >unregister_driver - looking for
> >clients.
> >Apr 10 01:56:44 coredump kernel: i2c_adapter i2c-2: examining adapter
> >Apr 10 01:56:44 coredump kernel: i2c-core.o: detaching client lm80:
> >Apr 10 01:56:44 coredump kernel: i2c-core.o: detaching client lm80:
> >Apr 10 01:56:44 coredump kernel: i2c-core: driver unregistered: lm80
> >Apr 10 01:56:48 coredump kernel: i2c_adapter i2c-2: Adapter 
> >unregistered
> >Apr 10 01:56:48 coredump kernel: i2c_adapter i2c-2: adapter 
> >unregistered
> >Apr 10 01:56:55 coredump kernel: eth0: wait_for_cmd_done timeout!
> >Apr 10 01:56:55 coredump kernel: Command 00ff never accepted 
> >(201 polls)!
> >Apr 10 01:56:55 coredump kernel: Command 0006 was not accepted 
> >after 20001
> >polls!  Current status ffffffff.
> >Apr 10 01:56:55 coredump kernel: Command 00ff never accepted 
> >(201 polls)!
> >Apr 10 01:56:55 coredump kernel: Command 0060 was not accepted 
> >after 20001
> >polls!  Current status ffffffff.
> >Apr 10 01:56:55 coredump kernel: eth0: wait_for_cmd_done timeout!
> >Apr 10 01:56:55 coredump kernel: Command 00ff never accepted 
> >(201 polls)!
> >Apr 10 01:56:55 coredump kernel: Command 0001 was not accepted 
> >after 20001
> >polls!  Current status ffffffff.
> >Apr 10 01:56:55 coredump kernel: Command 00ff never accepted 
> >(201 polls)!
> >Apr 10 01:56:56 coredump kernel: Command 0070 was not accepted 
> >after 20001
> >polls!  Current status ffffffff.
> >Apr 10 01:56:56 coredump kernel: eth0: wait_for_cmd_done timeout!
> >Apr 10 01:57:27 coredump last message repeated 26 times
> >Apr 10 01:57:29 coredump last message repeated 3 times
> >
> >-----Original Message-----
> >From: Feldman, Scott [mailto:scott.feldman@intel.com]
> >Sent: Wednesday, April 07, 2004 02:31 PM
> >To: Brown, Len; Shawn Starr
> >Subject: RE: [BUG][2.6.5 final][e100] NETDEV_WATCHDOG Timeout
> >- Was not a
> >problem with 2.6.5-rc3
> >
> >
> >> >Shawn, try turning off ACPI for interrupt routing.  Load the 
> >> >kernel
> >> >with the kernel parameter "noapci" set.
> >> 
> >> You mean "acpi=off", or "pci=noacpi".  If either of these fix the
> >> problem, please let me know.  (and send me the dmesg and 
> >> /proc/interrupts for both cases)
> >
> >Yes, sorry.  Can't believe I posted that to lkml.  Oh well.
> >
> >-scott
> >
> >
> 
