From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: can't add tc multiq
Date: Mon, 09 Feb 2009 11:43:26 +0300
Message-ID: <498FECAE.3020805@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:47083 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbZBIInc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 03:43:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 8CA37A6C6B0
	for <netdev@vger.kernel.org>; Mon,  9 Feb 2009 11:43:25 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id I3HHSPNgnjqp for <netdev@vger.kernel.org>;
	Mon,  9 Feb 2009 11:43:23 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTPA id 11887A6C6A7
	for <netdev@vger.kernel.org>; Mon,  9 Feb 2009 11:43:23 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all!
kernel 2.6.28.4
iproute2 - last git
Can't use multiq qdisc. How to fix this?
Thanks!

slavon ~ # tc qdisc add dev eth0 root handle 1: multiq
RTNETLINK answers: Invalid argument
slavon ~ # tc qdisc add dev eth1 root handle 1: multiq
RTNETLINK answers: Invalid argument


# lsmod
Module                  Size  Used by
sch_multiq              9472  0
8021q                  23200  0
xt_tcpudp               7040  0
iptable_filter          6784  0
ip_tables              15120  1 iptable_filter
x_tables               17028  2 xt_tcpudp,ip_tables
usbmouse                8064  0
usbhid                 37728  2
ehci_hcd               38284  0
snd_hda_intel         409776  6
uhci_hcd               26380  0
snd_pcm                72196  2 snd_hda_intel
usbcore               133136  7 usbmouse,usbhid,ehci_hcd,uhci_hcd
snd_timer              23304  2 snd_pcm
snd_page_alloc         12296  2 snd_hda_intel,snd_pcm
thermal                19356  0
snd_hwdep              11140  1 snd_hda_intel
processor              37024  1 thermal
i2c_i801               12944  0
snd                    52516  14 snd_hda_intel,snd_pcm,snd_timer,snd_hwdep
r8169                  36100  0
i2c_core               24724  1 i2c_i801
fglrx                1905884  3
e1000                 123076  0
rng_core                8196  0
mii                     8704  1 r8169
thermal_sys            15144  2 thermal,processor
button                 10128  0

