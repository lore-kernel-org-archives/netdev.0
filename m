From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tg3: netif_carrier_off runs too early; could still be
 queued when init fails
Date: Tue, 21 Feb 2006 16:35:17 -0800 (PST)
Message-ID: <20060221.163517.61593616.davem@davemloft.net>
References: <20060221.133947.05470613.davem@davemloft.net>
	<43FB9718.4050606@suse.com>
	<1140559048.20584.20.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffm@suse.com, akpm@osdl.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422639AbWBVAfe@vger.kernel.org>
To: mchan@broadcom.com
In-Reply-To: <1140559048.20584.20.camel@rh4>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 21 Feb 2006 13:57:28 -0800

> On Tue, 2006-02-21 at 17:41 -0500, Jeff Mahoney wrote:
> 
> > dmesg after modprobe tg3:
> > tg3.c:v3.49 (Feb 2, 2006)
> > ACPI: PCI Interrupt 0000:0a:02.0[A] -> GSI 24 (level, low) -> IRQ 201
> > Uhhuh. NMI received for unknown reason 21 on CPU 0.
> > Dazed and confused, but trying to continue
> > Do you have a strange power saving mode enabled?
> > tg3_test_dma() Write the buffer failed -19
> > tg3: DMA engine test failed, aborting.
> 
> You're getting an NMI during tg3_init_one() which means that the NIC is
> probably bad. I did a quick test on the same version of the 5701 NIC
> with the same tg3 driver and it worked fine.
> 
> Please find out if the NIC is known to be bad. Thanks.

I wonder if this is how this platform informs the cpu of master-abort
or target-abort cycles?  It could maybe also be an IRQ routing
problem...
