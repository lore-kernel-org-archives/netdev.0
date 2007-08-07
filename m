From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net/ibmveth.c: memset fix
Date: Tue, 07 Aug 2007 17:36:30 -0400
Message-ID: <46B8E5DE.2070107@garzik.org>
References: <200708062217.04361.m.kozlowski@tuxland.pl> <46B78672.9090808@linux.vnet.ibm.com> <46B78814.50508@pobox.com> <200708062344.03443.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, santil@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43185 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966596AbXHGVgf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 17:36:35 -0400
In-Reply-To: <200708062344.03443.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mariusz Kozlowski wrote:
>>>> 	Looks like memset() is zeroing wrong nr of bytes.
>>> Good catch, however, I think we can just remove this memset altogether
>>> since the memory gets allocated via kzalloc.
>> Correct, that memset() is superfluous.
> 
> Ok. Then this should do it.
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/ibmveth.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

applied


