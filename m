From: Dustin Schumm <shodid@gmail.com>
Subject: Re: Reoccuring kern.log events after running xl2tp with ethernet
 adapter Realtek 8111E
Date: Tue, 5 Jun 2012 10:56:53 -0400
Message-ID: <CANcVnzivnQrhSderZ+b5yoy+F1OiO7Ajv7WeijqzQKyAkYRqug@mail.gmail.com>
References: <CANcVnzi2mXKXZLcaAt9rJ9OOdK_2=V8JV9uebVeBcsDu6j+DhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:54668 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab2FEO4z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 10:56:55 -0400
Received: by wgbds11 with SMTP id ds11so3403286wgb.1
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 07:56:53 -0700 (PDT)
In-Reply-To: <CANcVnzi2mXKXZLcaAt9rJ9OOdK_2=V8JV9uebVeBcsDu6j+DhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let me start off by thanking you for helping with this.
I'm not that experienced with Linux so as to provide all surrounding
information, so let me know if you need more.
=46orgive me for sending this in plain test as I got a reject from
netdev for html.

The 816x for Ubuntu on kernel 3.2.0
r8169 0000:0c:00.0: eth0: RTL8168e/8111e at 0xf845e000,
bc:5f:f4:10:75:4b, XID 0c200000 IRQ 58
ethtool info
driver: r8169
version: 2.3LK-NAPI
firmware-version: rtl_nic/rtl8168e-2.fw
bus-info: 0000:0c:00.0

I've also tested with Fedora 17 using kernel 3.3.7
http://codepad.org/lxkcRLqp
This paste is from Fedora. Like Ubuntu, it starts with "general
protection fault: 0000 [#1] SMP" but does not give the other looping
messages after as in Ubuntu.
The 816x for Fedora is
r8169 0000:0c:00.0: eth0: RTL8168e/8111e at 0xf7e78000,
bc:5f:f4:10:75:4b, XID 0c200000 IRQ 60
ethtool info
driver: r8169
version: 2.3LK-NAPI
firmware-version: rtl_nic/rtl8168e-2.fw
bus-info: 0000:0c:00.0

and tested again with Cent OS 6.2 using kernel 2.6.32
Everything was functional without error here. I had replaced CentOS by
the time I got this mail so I hadn't captured the 816x here and forgot
to obtain the kern.log
ethtool info
driver: r8169
version: 2.3LK-NAPI
firmware-version:
bus-info: 0000:0c:00.0


>
> On Mon, Jun 4, 2012 at 7:10 PM, Francois Romieu <romieu@fr.zoreil.com=
> wrote:
> Dustin Schumm <shodid@gmail.com> :
> [...]
> > I'm more than happy to provide whatever more is needed.
>
> It does not look like our usual 816x bug reports... Neither does your
> setup actually.
>
> Which kind of 816x is it (see 'dmesg | grep XID' output) ?
>
> --
> Ueimor


> On Mon, Jun 4, 2012 at 1:39 PM, Dustin Schumm wrote:
>
> I'm using Ubuntu 12.04 kernel 3.2.0 and trying to set up L2TP over IP=
Sec using openswan and xl2tpd.=A0 I've got no problem with the ipsec an=
d I get SAs established. When I start the L2TP connection with xl2tpd, =
the kernel log starts filling with looping messages and PC becomes unus=
able.
>
> I have tested the exact same configuration down to every package in v=
isualization and all is working. I believe it has something to do with =
my ethernet hardware/driver on this machine or kernel interaction with =
that device. I'm looking for evidence that points to either the driver =
or kernel and possible solutions.
>
> I've tried compiling and installing the drivers from Realtek for the =
RTL8111E integrated adapter and using that, but it produced the same re=
sult. I've also tried a backported kernel 3.4.0
>
> I've posted a portion of my kern.log here from where i think the prob=
lem starts, http://codepad.org/QFbELkCr
>
> I'm more than happy to provide whatever more is needed.
>
> Thank you,
> Dustin S.
