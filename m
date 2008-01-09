From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Re : Re : Bonding : Monitoring of 4965 wireless card
Date: Wed, 09 Jan 2008 13:36:00 -0800
Message-ID: <1105.1199914560@death>
References: <168648.20508.qm@web25705.mail.ukl.yahoo.com>
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: patnel972-linux@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38887 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753447AbYAIVgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 16:36:03 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09La3qv002876
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 16:36:03 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09La2qr087170
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 14:36:02 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09La2Jc005912
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 14:36:02 -0700
In-reply-to: <168648.20508.qm@web25705.mail.ukl.yahoo.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patnel972-linux@yahoo.fr wrote:

>I ignore it, but it seems like it prevent bonding detect link of wlan0. I enslave wlan0 and i already use use_carrier=1;

	The default for bonding is use_carrier=1, which makes bonding
use the device driver's netif_carrier_on/off state for link detection.
Bonding only checks via ethtool/mii if use_carrier=0.

>I'll try arp monitoring but this is annoying i c'ant test localhost. Is there a way to test localhost with arp, without pass through lo ? 

	What do you mean by "test localhost with arp, without pass
through lo"?  ARP monitoring issues probes (ARPs) to a remote
destination to confirm that there is connectivity; I'm not sure what
localhost has to do with it.

	In general, though, I have not tested bonding with wireless
adapters, so I'm unfamiliar with how well it does or does not work.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
