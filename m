From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: network speed extremly slowed down
Date: Mon, 14 Mar 2005 11:57:57 -0800
Message-ID: <20050314115757.789a82d4@dxpl.pdx.osdl.net>
References: <200503141745.08032.bernd.schubert@pci.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
In-Reply-To: <200503141745.08032.bernd.schubert@pci.uni-heidelberg.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 17:45:06 +0100
Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de> wrote:

> Hi,
> 
> until one hour ago I thought this bug affects only 3com 3c509B cards. Now we 
> go on switching more and more systems from 2.4.X to 2.6.X and it seems that 
> many cards work much slower with 2.6.X
> 
> with 2.4.27:
> =========
> bernd@pc-brenn bernd>nttcp -T hamilton2
>      Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CPU-C/s
> l  8388608    0.72    0.02     92.7710   3355.4432    2048   2831.15  102400.0
> 1  8388608    0.73    0.04     92.0581   1864.3941    5783   7932.96  160661.2
> 
> with 2.6.11.3:
> ==========
> 
> bernd@pc-brenn bernd>nttcp -T hamilton2
>      Bytes  Real s   CPU s Real-MBit/s  CPU-MBit/s   Calls  Real-C/s   CPU-C/s
> l  8388608    3.29    3.28     20.3957     20.4569    2048    622.43     624.3
> 1  8388608    3.29    0.04     20.3923   1637.0411    6143   1866.67  149851.2
> 
> 
> Cards that show this behaviour:
> =======================
> Yukon Gigabit Ethernet 10/100/1000Base-T Adapter (sk98lin)
> 3Com PCI 3c905B Cyclone 100baseTx a
> eth0: VIA VT6102 Rhine-II 
> 
> Cards that work fine with 2.4.X and 2.6.X:
> ==============================
> 3Com PCI 3c905C Tornado
> 
> 
> The drivers always claim they are using full duplex, here e.g.:
> 
> eth0: network connection up using port A
>     speed:           100
>     autonegotiation: yes
>     duplex mode:     full
>     flowctrl:        none
>     irq moderation:  disabled
>     scatter-gather:  enabled
>
Are there any errors reported? Cpu time sees high perhaps the console log
is filling with messages or something.
