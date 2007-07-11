From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 16:24:20 +0400
Message-ID: <4694CBF4.8090303@openvz.org>
References: <4694A363.2070406@openvz.org> <200707111254.24352.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>, devel@openvz.org,
	Kirill Korotaev <dev@openvz.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:21552 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764061AbXGKMYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 08:24:24 -0400
In-Reply-To: <200707111254.24352.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Borntraeger wrote:
> Am Mittwoch, 11. Juli 2007 schrieb Pavel Emelianov:
>>  drivers/net/veth.c   |  452 
>>  include/net/veth.h   |   14 +
> 
> I know, I am late in the game, but wont the name collide somewhat with 
> drivers/net/ibmveth.h, drivers/net/iseries_veth.c, and drivers/net/ibmveth.c?

David asked the same thing after v.1. The answer is :
No it will not. These devices use eth%d strings to generate their names.

> Christian
> 

Thanks,
Pavel
