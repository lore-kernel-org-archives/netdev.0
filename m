From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 04:55:51 -0800 (PST)
Message-ID: <20090305.045551.49612040.davem@davemloft.net>
References: <49AE69DD.80802@trash.net>
	<20090304.195328.106253933.davem@davemloft.net>
	<1236256226.18385.30.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, bart@jukie.net, greearb@candelatech.com,
	shemminger@vyatta.com, dada1@cosmosbay.com,
	frank.blaschka@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752992AbZCEM4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 07:56:06 -0500
In-Reply-To: <1236256226.18385.30.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Bizon <mbizon@freebox.fr>
Date: Thu, 05 Mar 2009 13:30:26 +0100

> Any reason dev->stop is not in this list ?

dev->stop is only called from net/core/dev.c and it is
netdev_ops aware :-)
