From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 12 Nov 2003 02:05:35 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB1DBBF.1010403@pobox.com>
References: <20031011105054.0e16a607.davem@redhat.com> <3F8C290A.3010508@sgi.com> <20031014095323.71c8b9fe.davem@redhat.com> <3FB03A56.7000709@sgi.com> <20031110182911.2c5a121b.davem@redhat.com> <3FB140E2.1070007@sgi.com> <20031111122403.2d7bcf28.davem@redhat.com> <3FB15725.4050705@sgi.com> <20031111235330.GA25553@wotan.suse.de> <3FB190FE.20005@sgi.com> <20031112061958.GA12065@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Partridge <johnip@sgi.com>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com, jes@sgi.com, David Mosberger <davidm@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031112061958.GA12065@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>--- linux/arch/ia64/Kconfig     2003-10-25 13:44:46.000000000 -0500
>>+++ patch/arch/ia64/Kconfig     2003-11-11 19:45:06.000000000 -0600
>>@@ -468,6 +468,10 @@
>>          agent" (/sbin/hotplug) to load modules and set up software needed
>>          to use devices as you hotplug them.
>>
>>+config CONFIG_UNALIGNED_EXPENSIVE
> 
> 
> Sorry to nitpick again and not catching it earlier, but are you sure it works 
> this way? Normally the options in Kconfig are not prefixed with CONFIG_* 
> 
> So 
> 
> config UNALIGNED_EXPENSIVE 
> 
> would be likely correct


indeed.

For my part, I will apply the patch to drivers/net/tg3.c, which is fine, 
and will let the arch/ia64/Kconfig patch go through normal channels 
(since ia64 seems to be flowing these days).

	Jeff
