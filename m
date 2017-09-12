From: Benoit Panizzon <benoit.panizzon@imp.ch>
Subject: Re: broken vlan support on Realtek RTL8111/8168/8411 rev 9
Date: Tue, 12 Sep 2017 13:07:24 +0200
Message-ID: <20170912130724.11c34f13@go.imp.ch>
References: <20170910191645.549d2a3a@krup.woody.ch>
        <20170911222325.GA23162@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thor.imp.ch ([157.161.4.18]:50243 "EHLO thor.imp.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751373AbdILLH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 07:07:26 -0400
In-Reply-To: <20170911222325.GA23162@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois

> ethtool -K eth0 rxvlan off

Thank you, that did the trick, vlan tags are not correctly passed on
and not set to vlan 0 with rxvlan turned off.
 
> For my reward, please send a complete dmesg where the messages from
> the vanilla r8169 module appear for the rev 09 card (r81..f ?). I
> won't dig it right now.

Yes, the 'f' variant:

[    1.035203] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.035262] r8169 0000:03:00.0: setting latency timer to 64
[    1.035348] r8169 0000:03:00.0: irq 41 for MSI/MSI-X
[    1.035634] r8169 0000:03:00.0: eth0: RTL8168f/8111f at 0xffffc90000c28000, c8:60:00:dd:f8:6c, XID 08000800 IRQ 41
[    1.035637] r8169 0000:03:00.0: eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
[   10.403921] r8169 0000:03:00.0: firmware: agent loaded rtl_nic/rtl8168f-1.fw into memory

Linux pulsar 4.9.0-3-amd64 #1 SMP Debian 4.9.30-2+deb9u2 (2017-06-26) x86_64 GNU/Linux

624831688e25aa47fa84c30c045fcae3  /lib/firmware/rtl_nic/rtl8168f-1.fw

Firmware Bug or Hardware Problem?

-Benoît Panizzon-
-- 
I m p r o W a r e   A G    -    Leiter Commerce Kunden
______________________________________________________

Zurlindenstrasse 29             Tel  +41 61 826 93 00
CH-4133 Pratteln                Fax  +41 61 826 93 01
Schweiz                         Web  http://www.imp.ch
______________________________________________________
