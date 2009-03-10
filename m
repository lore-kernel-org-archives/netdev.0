From: Felix Radensky <felix@embedded-sol.com>
Subject: RX problem in ibm_newemac driver
Date: Tue, 10 Mar 2009 21:50:58 +0200
Message-ID: <49B6C4A2.8060302@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:38160 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753772AbZCJTvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 15:51:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm experiencing RX problem on custom board based on AMCC
405EXr processor. Channel 0 of EMAC is connected to 10/100
Micrel KSZ8041NL PHY in MII mode. Ethernet works fine in
u-boot (version 2009.01). In Linux (2.6.27) Ethernet works fine
as well if EMAC was initialized in u-boot. It is enough to send
ping from u-boot (even to non-existing host) to make things work
in linux. But if u-boot takes kernel and ramdisk images from flash
and does not initialize EMAC only TX side works in linux.

I can see that TX counters are incremented when pinging from
EMAC side, but RX counters remain zero.  RX error counter
in PHY is zero as well.  I've enabled debugging in EMAC
driver and verified that RX EOB interrupt is not triggered.
FER register in RGMII bridge is properly configured for MII
mode on channel 0.  I've tried to dump EMAC registers using
ethtool and got machine check exception.

I don't know what else could be done to identify the source of
the problem. Any tips would be greatly appreciated.

Thanks.

Felix.
