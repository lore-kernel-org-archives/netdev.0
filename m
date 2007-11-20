From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 4/6] net: Make AF_PACKET handle multiple network
 namespaces
Date: Mon, 19 Nov 2007 22:33:50 -0800 (PST)
Message-ID: <20071119.223350.241597054.davem@davemloft.net>
References: <20071115155954.GA25475@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753418AbXKTGdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:33:50 -0500
In-Reply-To: <20071115155954.GA25475@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 15 Nov 2007 18:59:54 +0300

> This is done by making packet_sklist_lock and packet_sklist per
> network namespace and adding an additional filter condition on
> received packets to ensure they came from the proper network
> namespace.
> 
> Changes from v1:
> - prohibit to call inet_dgram_ops.ioctl in other than init_net
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
