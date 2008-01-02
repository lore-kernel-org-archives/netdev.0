From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.23.12] net/bonding: option to specify initial bond interface number
Date: Wed, 02 Jan 2008 14:24:23 -0800
Message-ID: <22042.1199312663@death>
References: <413FEEF1743111439393FB76D0221E4809790942@leopard.zoo.q9networks.com>
Cc: netdev@vger.kernel.org
To: "Jari Takkala" <Jari.Takkala@Q9.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56461 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbYABWYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 17:24:30 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m02LLuDd013392
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 16:21:56 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m02MOPQH116176
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 15:24:25 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m02MOOTr019692
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 15:24:24 -0700
In-reply-to: <413FEEF1743111439393FB76D0221E4809790942@leopard.zoo.q9networks.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jari Takkala <Jari.Takkala@Q9.com> wrote:

>Allow the user to specify an initial interface number when loading the bonding driver. This is useful when loading multiple instances of the bonding driver and you want to control the interface number assignment. For example, if the user wishes to create a bond5 interface they can type 'modprobe -o bond5 bonding ifnum=5'. It also works with the max_bonds option.

	What advantage does this have over:

# echo +bond5 > /sys/class/net/bonding_masters

	which will create a new bonding master for the already-loaded
driver?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
