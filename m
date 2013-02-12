From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: bonding 802.3ad mode with bridge and tap devices
Date: Tue, 12 Feb 2013 10:33:24 +0100
Message-ID: <511A0C64.1010602@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, Linux Netdev List <netdev@vger.kernel.org>
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:46778 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab3BLJda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 04:33:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

i'm using KVM with tapdevices on vanilla 3.7.7 kernel.

Layout:

eth0 ------
           | -- bond0 --- vmbr0 ---- tap
eth1 ------

This works fine as long as i use active-backup mode. But if i switch to
802.3ad mode the host using vmbr0 as his default gw works fine but the
tap device does not.

It starts to work fine again if i set eth0/eth1 into promiscious mode.
Is this a kernel bug or my fault?

Thanks!

Greets,
Stefan
