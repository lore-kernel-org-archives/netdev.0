From: James Drabb <JDrabb@tampabay.rr.com>
Subject: Re: forcedeth
Date: Sun, 01 Aug 2004 18:01:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410D682F.4090809@tampabay.rr.com>
References: <410D3377.3030505@tampabay.rr.com> <410D4120.2020604@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, c-d.hailfinger.kernel.2004@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <410D4120.2020604@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> James Drabb wrote:
> 
>> jim@keelie $ uname -a
>> Linux keelie 2.6.7-1 #1 Thu Jul 22 11:42:58 CEST 2004 i686 athlon i386 
>> GNU/Linux
> 
> 
> There should be a message in the dmesg log about the driver version: If 
> it's less than 0.28: could you try a newer kernel? 0.28 is definitively 
> in 2.5.8-rc1-mm1 and later. I could also send you just the forcedeth.c 
> file, then you don't have to upgrade the whole kernel.

dmesg shows version 0.25.

> Probably the phy reset and/or the media detection do not work properly. 
> That part is completely rewritten in 0.28.
> 
> I'm interested in two infos:
> - with 2.6.7 (probably version 0.25), after booting into winXP first: 
> what does
>    # ethtool eth0
> report? Then unplug the network cable. Run ethtool again. Does it report 
> "Link detected: No"? What if you plug the network cable back in?

ethtool eth0 shows:

Settings for eth0:
         Supports Wake-on: g
         Wake-on: d
         Link detected: yes

Unplugging the network cable showed the same settings:

Settings for eth0:
         Supports Wake-on: g
         Wake-on: d
         Link detected: yes

> -- 
>    Manfred

Please send me the latest forcedeth.c and I will give it a go.  Do you 
have the makefile so I can compile the module outside of the kernel?

Thanks,

Jim Drabb
-- 
James Drabb
Senior Programmer
Davenport, FL USA
