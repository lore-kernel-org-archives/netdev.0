From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: tg3 pxe weirdness
Date: Fri, 22 Sep 2017 11:51:50 +0530
Message-ID: <CAMet4B4Jdgjs42KAWQ4HJr1t_Grn1_+Hv8sipeLb_tvZ_SFrMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Berend De Schouwer <berend.de.schouwer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:43738 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751790AbdIVGVw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 02:21:52 -0400
Received: by mail-qt0-f175.google.com with SMTP id i50so147212qtf.0
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 23:21:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 7:53 PM, Berend De Schouwer
<berend.de.schouwer@gmail.com> wrote:
> Hi,
>
> I've got a machine with a Broadcom bcm5762c, using the tg3 driver, that
> fails to receive network packets under some very specific conditions.
>
> It works perfectly using a 1Gbps switch.  If, however, it first uses
> PXE and then loads the Linux tg3 driver, and the switch is 100Mbps, it
> no longer receives packets larger than ICMP.
>
> It does do ARP and ping.
>
> If it boots using PXE on a 1Gbps switch, boots into Linux, and then
> it's plugged into 100 Mbps it also stops receiving packets.
>
> mii-diag and dmesg confirm auto-negotiated speed and flow control, and
> confirm temporary disconnect as the cables are moved.
>
> PXE boots using UNDI, which then transfers a kernel using TFTP, which
> transfers correctly.  The kernel boots, loads the tg3 driver, connects
> the network.  Up to this point everything works.  Ping will work too.
> Any other network traffic fails.
>
> Booting from a harddrive works fine.  I assume the UNDI driver
> somewhere breaks auto-negotiation.  I've tried using mii-tool and
> ethtool, but I haven't managed to make it work yet.
>
> Is it possible to get negotiation working after PXE boot?  Are there
> any tg3 driver flags that might make a difference?
>
>
> Berend

Can you please share below details?
1) Model and Manufacturer of the system
2) Linux distro/kernel used?
