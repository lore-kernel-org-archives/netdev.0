From: Srihari Vijayaraghavan <harisri@telstra.com>
Subject: Re: [patch] 2.6.5-rc2 - r8169 DAC
Date: Mon, 05 Apr 2004 09:38:46 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <253ea2a8f4.2a8f4253ea@email.bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, ak@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com
Content-language: en
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello Francois,

> DMA_{32/64}BIT_MASK for all.
> 
> 
> include/linux/dma-mapping.h |    3 +++
> 1 files changed, 3 insertions(+)
> 
> diff -puN include/linux/dma-mapping.h~r8169-dac-00 
> include/linux/dma-mapping.h

With that patch 2.6.5-rc2 + r8169 DAC compiles and works fine.

There is one problem however: If I unplug and plug the cable it does not come back to online (even the LED on the card does not glow). I did not try reloading the driver, but a reboot does fix it :-( (later today I shall try reloading the driver). OTOH the vanilla 2.6.5-rc2 (or rc3) does not show this behaviour.

As for as the stability, I have stress tested it for couple of hours and it seems to work just fine.

Thanks
Hari
                                                                      
