From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc4-mm1: eth0: trigger_send() called with the
 transmitter busy
Date: Mon, 14 Aug 2006 09:50:16 -0700
Message-ID: <20060814095016.04d178ab.akpm@osdl.org>
References: <20060813012454.f1d52189.akpm@osdl.org>
	<44E08AF7.9060508@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54924 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932144AbWHNQuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 12:50:19 -0400
To: Laurent Riffard <laurent.riffard@free.fr>
In-Reply-To: <44E08AF7.9060508@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006 16:38:47 +0200
Laurent Riffard <laurent.riffard@free.fr> wrote:

> Le 13.08.2006 10:24, Andrew Morton a __crit :
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc4/2.6.18-rc4-mm1/
> 
> Hello,
> 
> This morning, while trying to suspend to disk, my box started to loop 
> displaying the following message:
> eth0: trigger_send() called with the transmitter busy.
> 
> Here is the scenario. I booted 2.6.18-rc4-mm1 with this command line:
> root=/dev/vglinux1/lvroot video=vesafb:ywrap,mtrr splash=silent resume=/dev/hdb7 netconsole=@192.163.0.3/,@192.168.0.1/00:0E:9B:91:ED:72 init 1
> 
> Then I issued:
> # echo 6 > /proc/sys/kernel/printk
> # echo disk > /sys/power/state

ne2k isn't <ahem> the most actively-maintained driver.

But most (I think all) net drivers have problems during suspend when
netconsole is active.  Does disabling netconsole help?

Did this operation work OK in earlier kernels, with netconsole enabled?
