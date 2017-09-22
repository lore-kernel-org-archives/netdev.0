From: Berend De Schouwer <berend.de.schouwer@gmail.com>
Subject: Re: tg3 pxe weirdness
Date: Fri, 22 Sep 2017 09:28:23 +0200
Message-ID: <1506065303.18177.78.camel@gmail.com>
References: <CAMet4B4Jdgjs42KAWQ4HJr1t_Grn1_+Hv8sipeLb_tvZ_SFrMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Siva Reddy Kallam <siva.kallam@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36167 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdIVH23 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 03:28:29 -0400
Received: by mail-wr0-f193.google.com with SMTP id g50so165658wra.3
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 00:28:29 -0700 (PDT)
In-Reply-To: <CAMet4B4Jdgjs42KAWQ4HJr1t_Grn1_+Hv8sipeLb_tvZ_SFrMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 11:51 +0530, Siva Reddy Kallam wrote:
> On Thu, Sep 21, 2017 at 7:53 PM, Berend De Schouwer
> <berend.de.schouwer@gmail.com> wrote:
> > Hi,
> > 
> > I've got a machine with a Broadcom bcm5762c, using the tg3 driver,
> > that
> > fails to receive network packets under some very specific
> > conditions.
> > 
> > 
> > Berend
> 
> Can you please share below details?
> 1) Model and Manufacturer of the system

HP EliteDesk 705 G3 SFF
lspci -n on the network card: 01:00.0 0200: 14e4:1687 (rev 10)

dmesg from tg3: 
tg3 0000:01:00.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
tg3 0000:01:00.0: setting latency timer to 64
tg3 0000:01:00.0: eth0: Tigon3 [partno(none) rev 5762100] (PCI Express)
MAC address 70:5a:0f:3d:9f:4f
tg3 0000:01:00.0: eth0: attached PHY is 5762C (10/100/1000Base-T
Ethernet) (WireSpeed[1], EEE[1])
tg3 0000:01:00.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0]
TSOcap[1]
tg3 0000:01:00.0: eth0: dma_rwctrl[00000001] dma_mask[64-bit]

The same motherboard with add-on network cards does boot using PXE. 
It's an EFI board but Secureboot is currently disabled.


> 2) Linux distro/kernel used?

CentOS 6 + updates.  I've tried all the CentOS 6 kernels up to 2.6.32-
696.10.2.el6.x86_64

I've tried updating the tg3 driver from 3.137 to both 3.137h and
3.137o, with the same result.

I'm currently in the process of making 4.13.2 boot.
