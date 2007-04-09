From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: APIC error on 32-bit kernel
Date: Mon, 09 Apr 2007 13:59:48 -0400
Message-ID: <461A7F14.1080105@redhat.com>
References: <20070323200817.1f3e39b9@osprey.hogchain.net> <20070408133822.3868e6ff@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752221AbXDIR74@vger.kernel.org>
In-Reply-To: <20070408133822.3868e6ff@osprey.hogchain.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> [Adding linux-kernel to the cc list, hoping for wider exposure.]
> 
> On Fri, 23 Mar 2007 20:08:17 -0500
> Jay Cliburn <jacliburn@bellsouth.net> wrote:
> 
>> We're trying to track down the source of a problem that occurs
>> whenever the atl1 network driver is activated on a 32-bit 2.6.21-rc4
> 
> and -rc5, -rc6, 2.6.20.x, 2.6.19.3, and probably others.
> 
>> We can load the driver just fine, but whenever we activate the
>> network, we see APIC errors (a sample of them are shown here,
>> captured from a serial console):
>>
>> [root@hawk ~]# echo 8 > /proc/sys/kernel/printk
>> [root@hawk ~]# [   93.942012] process `sysctl' is using deprecated
>> sysctl (sysc.
>> [   94.396609] atl1: eth0 link is up 1000 Mbps full duplex
>> [   94.498887] APIC error on CPU0: 00(08)
>> [   94.498534] APIC error on CPU1: 00(08)
>> [   94.550079] APIC error on CPU0: 08(08)
>> [   94.549725] APIC error on CPU1: 08(08)
>> [   94.600915] APIC error on CPU1: 08(08)
>> [   94.601276] APIC error on CPU0: 08(08)
>> [   94.652108] APIC error on CPU1: 08(08)
>> [   94.652470] APIC error on CPU0: 08(08)
>> [   94.703659] APIC error on CPU0: 08(08)
>> [   94.703305] APIC error on CPU1: 08(08)
>> [   94.754852] APIC error on CPU0: 08(40)
>> [   94.806045] APIC error on CPU0: 40(08)
>> [   94.805692] APIC error on CPU1: 08(08)
>> [   94.857238] APIC error on CPU0: 08(08)
>> [   94.856884] APIC error on CPU1: 08(08)
>> [   94.908432] APIC error on CPU0: 08(08)
>> [   94.908078] APIC error on CPU1: 08(08)
>> [snip, more of the same]
>> [   98.901156] APIC error on CPU1: 08(08)
>> [   98.952702] APIC error on CPU0: 08(08)
>> [   98.952349] APIC error on CPU1: 08(08)
>> [   99.003895] APIC error on CPU0: 08(08)
>> [   99.003542] APIC error on CPU1: 08(08)
>>
>> The machine hangs for about 5-10 seconds, then spontaneously reboots
>> without further console output.
> 
> I can prompt an oops by pinging my router while the apic errors are
> scrolling by.

Where is the text of the oops?


> 
