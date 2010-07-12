From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next-2.6]  macvtap: Return error when macvlan drops the packet
Date: Mon, 12 Jul 2010 12:44:04 +0200
Message-ID: <201007121244.04499.arnd@arndb.de>
References: <1278924474.7719.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org, davem@davemloft.net
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:51474 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab0GLKoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 06:44:19 -0400
In-Reply-To: <1278924474.7719.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 12 July 2010, Shirley Ma wrote:
> 
> Return err when macvlan dropps the packet.

Can you be more specific why you think this is the right idea?

As far as I can tell, this will return '1' to user space for a dropped
packet (NET_XMIT_DROP) or another positive return value.
While this might be nice for a user application to know, neither does
qemu check for this nor does it match the read(2) documentation.

I fear if we want congestion control to improve, we need to do it
differently.

	Arnd
