From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Rework dev_base via list_head (v2)
Date: Thu, 03 May 2007 13:44:17 +0200
Message-ID: <4639CB11.2050508@trash.net>
References: <4639C95A.3030809@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Kirill Korotaev <dev@sw.ru>, devel@openvz.org
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60340 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031153AbXECLpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 07:45:49 -0400
In-Reply-To: <4639C95A.3030809@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Cleanup of dev_base list use, with the aim to simplify making
> device list per-namespace. In almost every occasion, use of
> dev_base variable and dev->next pointer could be easily replaced
> by  for_each_netdev loop. A few most complicated places were
> converted to using first_netdev()/next_netdev().
> 
> Changes:
> * David's comment about loop termination;
> * Applies to todays netdev git tree.


This seems to be missing fs/afs/netdevices.c.
