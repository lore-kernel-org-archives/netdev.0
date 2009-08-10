From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] can: Fix raw_getname() leak
Date: Sun, 09 Aug 2009 21:52:21 -0700 (PDT)
Message-ID: <20090809.215221.220159369.davem@davemloft.net>
References: <4A7BC938.8010504@gmail.com>
	<4A7BCA5F.9050102@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752061AbZHJEwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:52:11 -0400
In-Reply-To: <4A7BCA5F.9050102@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Fri, 07 Aug 2009 08:31:59 +0200

> Eric Dumazet wrote:
>> raw_getname() can leak 10 bytes of kernel memory to user
>> 
>> (two bytes hole between can_family and can_ifindex,
>> 8 bytes at the end of sockaddr_can structure)
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied.
