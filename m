From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] drivers/net/ibmveth.c: memset fix
Date: Mon, 06 Aug 2007 16:44:04 -0400
Message-ID: <46B78814.50508@pobox.com>
References: <200708062217.04361.m.kozlowski@tuxland.pl> <46B78672.9090808@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>, santil@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: brking@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34654 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756084AbXHFUoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 16:44:11 -0400
In-Reply-To: <46B78672.9090808@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> Mariusz Kozlowski wrote:
>> Hello,
>>
>> 	Looks like memset() is zeroing wrong nr of bytes.
> 
> Good catch, however, I think we can just remove this memset altogether
> since the memory gets allocated via kzalloc.

Correct, that memset() is superfluous.

	Jeff



