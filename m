From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Problem with GVRP on eth while having a bridge
Date: Thu, 07 Feb 2013 11:56:38 +0100
Message-ID: <51138866.8000802@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexandre DERUMIER <aderumier@odiso.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:53213 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755815Ab3BGLDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 06:03:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello list,

this was tested using vanilla 3.7.6 kernel.

When i add a vlan to an ethernet device supporting gvrp everything is
fine until this ethernet device also had a bridge.

This works fine as long as eth1 is not attached to a bridge.

# ip link add link eth1 name eth1.99 type vlan id 99 gvrp on
# ip link set eth1.99 up

The dynamic VLAN stays up at the switch - no problems.

If eth1 has a bridge the dynamic vlan is created at the switch so the
initial packet was send but it disappears after a few seconds.

Wireshark shows that the kernel has stopped sending GVRP packets. After
adding a bridge to eth1.

Greets,
Stefan
