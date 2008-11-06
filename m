From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not
 respected
Date: Wed, 05 Nov 2008 17:46:28 -0800
Message-ID: <1225935988.12402.1.camel@HP1>
References: <C27F8246C663564A84BB7AB343977242151F4B18B5@IRVEXCHCCR01.corp.ad.broadcom.com>
 <491154C8.3040401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux kernel" <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4654 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464AbYKFBs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 20:48:57 -0500
In-Reply-To: <491154C8.3040401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-11-05 at 00:09 -0800, Eric Dumazet wrote:
> Thanks Michael for your fast answer
> 
> 
> I tried this MSI disabling and yes, it now works.
> 
>  16:      42726        128        105        106         89         89
> 145        152   IO-APIC-fasteoi   uhci_hcd:usb1, eth0, eth1
> 
> But I now have same interrupt used on two NIC, so I cannot split the
> load on two CPUS, unless
> using a smp_affinity with 2 CPUS on it. Not exactly what I wanted to
> do..
> 
> Do you know if BCM5715S (tg3 driver) have same problem ?

Eric, I believe the 5715 should be OK.


