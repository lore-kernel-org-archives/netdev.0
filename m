From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: network speed extremly slowed down
Date: Mon, 14 Mar 2005 09:21:53 -0800
Message-ID: <20050314092153.79ae93f1@dxpl.pdx.osdl.net>
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

What type is the other host (hamilton2) and what is the round trip delay?
Is it on the same local network?
