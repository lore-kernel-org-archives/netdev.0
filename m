From: James Drabb <JDrabb@tampabay.rr.com>
Subject: forcedeth
Date: Sun, 01 Aug 2004 14:16:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410D3377.3030505@tampabay.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: c-d.hailfinger.kernel.2004@gmx.net, manfred@colorfullife.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am having some issues with the forcedeth driver.

jim@keelie $ modinfo forcedeth
parm:           max_interrupt_work:forcedeth maximum events handled per 
interrupt
author:         Manfred Spraul <manfred@colorfullife.com>
description:    Reverse Engineered nForce ethernet driver
license:        GPL
vermagic:       2.6.7-1 686 REGPARM gcc-3.3
depends:
alias:          pci:v000010DEd000001C3sv*sd*bc*sc*i*
alias:          pci:v000010DEd00000066sv*sd*bc*sc*i*
alias:          pci:v000010DEd000000D6sv*sd*bc*sc*i*

jim@keelie $ uname -a
Linux keelie 2.6.7-1 #1 Thu Jul 22 11:42:58 CEST 2004 i686 athlon i386 
GNU/Linux

My system is an Athlon XP 2800+, on an MSI K7N2 Delta Mobo based on the 
NForce 2 chipset.  I have a dual boot with WinXP and Fedora Core 2 and 
spend 99% of my time in FC2.  Once in a while I shut the system down. 
When I boot from a cold boot right into FC2, the forcedeth driver 
appears not to work.  I am not able to get to the net over my cable 
mode.  Bringing eth0 up and down, unplugging the network cable does 
nothing.  However, if I reboot into WinXP, and then reboot right away 
back into FC2, the forcedeth driver works like a champ.

Is there anything I can do to look into what might be causing this 
issue?  Any more information I may be able to send to help?

Thanks for any help,

-- 
James Drabb
Senior Programmer
Davenport, FL USA
