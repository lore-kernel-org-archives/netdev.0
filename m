From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [net-next 6/10] bnx2x: Update vlan_features
Date: Thu, 23 Jul 2009 11:47:37 -0700
Message-ID: <2588.1248374857@death.nxdomain.ibm.com>
References: <1248191263.18195.49.camel@lb-tlvb-eilong> <4A683F83.1060701@trash.net> <4A68462C.1080709@Voltaire.com> <4A68479F.1000807@trash.net> <4A6849D6.4050200@voltaire.com>
Cc: Patrick McHardy <kaber@trash.net>, eilong@broadcom.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39272 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbZGWSrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 14:47:37 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6NIjpMl025974
	for <netdev@vger.kernel.org>; Thu, 23 Jul 2009 12:45:51 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6NIlaed224254
	for <netdev@vger.kernel.org>; Thu, 23 Jul 2009 12:47:36 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6NIlZVf013968
	for <netdev@vger.kernel.org>; Thu, 23 Jul 2009 12:47:35 -0600
In-reply-to: <4A6849D6.4050200@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>okay, understood. So the patches to bnx2 and bnx2x can/should be made
>simpler and the patch to bonding has to change and include a call to
>netdev_features_change(), Jay, I assume you prefer to do that, if not, let
>me know and I will.

	I'm working on the new bonding patch; adding the
netdev_features_change call has locking implications, so the calls to
bond_compute_features have to move around a bit.

	Should have something later today.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
