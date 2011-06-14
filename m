From: Alexander Smirnov <Alexander.Smirnov@siemens.com>
Subject: compression format for ipv6 in low power networks (6lowpan)
Date: Tue, 14 Jun 2011 19:55:13 +0400
Message-ID: <4DF78461.3080109@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thoth.sbs.de ([192.35.17.2]:33867 "EHLO thoth.sbs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab1FNQCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 12:02:05 -0400
Received: from mail3.siemens.de (localhost [127.0.0.1])
	by thoth.sbs.de (8.13.6/8.13.6) with ESMTP id p5EFuHn2007578
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2011 17:56:17 +0200
Received: from [163.242.202.75] ([163.242.202.75])
	by mail3.siemens.de (8.13.6/8.13.6) with ESMTP id p5EFuG7J031882
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2011 17:56:17 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

could anybody please give me an advice.

Currently I have 802.15.4 network stack prototype in Linux 
(https://sourceforge.net/projects/linux-zigbee/),
and I want to add IPv6 support. So it needs to add IPv6 header 
encapsulation/decapsulation above 802.15.4 layer.

What's the best way to do it in Linux (something like ipv6-ipv6 
tunnel...)? Where this code must be stored, in 'ipv6' folder or in 
'mac802154'?

Thank you,
Alexander
