From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: NAPI for eepro100
Date: Wed, 12 Jun 2002 19:00:00 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae8k4b$4t0$2@main.gmane.org>
References: <3D0740ED.2060907@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@oss.sgi.com, saw@saw.sw.com.sg, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Zhang Fuxin <fxzhang@ict.ac.cn>
List-Id: netdev.vger.kernel.org

Zhang Fuxin wrote:
> hi,all
>   Recently i've converted eepro100 driver to use napi,in order to improve
> network performance of my poor 150M mips machine. It does eliminate
> the interrupt live lock seen before,maintaining a peak throughput under
> heavy load.
>  In case anybody are interested,i post the patches to the list. They are
> 3 incremental patchs:
>   eepro100-napi.patch is against 2.5.20 eepro100.c and provide basic
> napi support

Nifty, I'll take a look at this.


>   eepro100-proc.patch is proc file system support adapted from intel's
> e100 driver. I am using it for debugging.
>   eepro100-mips.patch is mips specific patch to make it work(well) for 
> my mips
> platform.


Just FWIW I'm not gonna apply these... for the 'proc' patch, that either 
needs to be moved to ethtool, or we should make a filesystem for net 
drivers that exports procfs-like inodes.  for the 'mips' patch, it looks 
like the arch maintainer(s) need to fix the PCI DMA support...

	Jeff
