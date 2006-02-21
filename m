From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: netif_carrier_off runs too early; could still
 be queued when init fails
Date: Tue, 21 Feb 2006 13:57:28 -0800
Message-ID: <1140559048.20584.20.camel@rh4>
References: <20060220194337.GA21719@locomotive.unixthugs.org>
 <1140540260.20584.6.camel@rh4>
 <20060221.133947.05470613.davem@davemloft.net>
 <43FB9718.4050606@suse.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, akpm@osdl.org,
	torvalds@osdl.org, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751227AbWBUXit@vger.kernel.org>
To: "Jeff Mahoney" <jeffm@suse.com>
In-Reply-To: <43FB9718.4050606@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-02-21 at 17:41 -0500, Jeff Mahoney wrote:

> 
> dmesg after modprobe tg3:
> tg3.c:v3.49 (Feb 2, 2006)
> ACPI: PCI Interrupt 0000:0a:02.0[A] -> GSI 24 (level, low) -> IRQ 201
> Uhhuh. NMI received for unknown reason 21 on CPU 0.
> Dazed and confused, but trying to continue
> Do you have a strange power saving mode enabled?
> tg3_test_dma() Write the buffer failed -19
> tg3: DMA engine test failed, aborting.
> 

You're getting an NMI during tg3_init_one() which means that the NIC is
probably bad. I did a quick test on the same version of the 5701 NIC
with the same tg3 driver and it worked fine.

Please find out if the NIC is known to be bad. Thanks.
