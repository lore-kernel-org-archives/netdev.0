From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: 802.1Q support?
Date: Mon, 12 Jan 2009 11:48:26 -0500
Message-ID: <200901121148.26905.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:13330 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbZALQ5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 11:57:52 -0500
Received: from nwd2exm5.ad.analog.com (nwd2exm5.ad.analog.com [10.64.51.20])
	by nwd2mhb1.analog.com (8.9.3 (PHNE_28810+JAGae91741)/8.9.3) with ESMTP id LAA19985
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 11:48:11 -0500 (EST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to understand the "standard" way to control a switch which supports 
VLAN.

Pick any one of:
 
Infineon XWAY ADM6999 (eight-port 10/100 plus one MII) 
http://www.infineon.com/cms/en/product/channel.html?channel=ff80808112ab681d0112ab68ce8d0043
 
Micrel MS8993M (2 port 10/100 plus one MII)
http://www.micrel.com/_PDF/Ethernet/ks8993m_pb.pdf 
 
Broadcom BCM5325E (five port 10/100 plus one MII)
http://www.broadcom.com/collateral/pb/5325E-PB00-R.pdf
 
Realtek (five port 10/100 plus one MII) 
http://www1.futureelectronics.com/doc/REALTEK%20SEMICONDUCTOR/Realtek%20Semiconductor%20RTL8306SD-GR.pdf
 
They all have multiple MAC/PHYs which are exposed to the wire, and a single 
MII interface - which normally connects directly to a SOC's MII/MAC.

I would have thought that there would be separate drivers for these in the 
phylib, but I didn't find anything that looked like it would work. (or expose 
the right interface (all the vendor specific VLAN registers) so I can program 
them properly from userspace)...

It is possible to hack up the specific EMAC driver to do everything, but that 
doesn't seem like the right way to do it...

Any pointers appreciated.

Thanks.

