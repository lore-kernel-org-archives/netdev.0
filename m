From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Subject: Re: [RFC PATCH] veth: keep peers MTU values synchronized
Date: Fri, 4 Apr 2014 19:04:51 +0400
Message-ID: <533ECA13.60305@securitycode.ru>
References: <533DD390.6020103@gmail.com>	<20140404.102518.2263545144702348056.davem@davemloft.net>	<533EC4D5.50304@securitycode.ru> <20140404.104921.1668611243816621886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <matvejchikov@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from itna.infosec.ru ([82.198.190.199]:17043 "EHLO itna.infosec.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbaDDPEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 11:04:10 -0400
In-Reply-To: <20140404.104921.1668611243816621886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.04.2014 18:49, David Miller wrote:
> From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
> Date: Fri, 4 Apr 2014 18:42:29 +0400
> 
>> Peers are created at once and ether_setup used for the configuration so MTU
>> values equals.
> 
> If an IFLA_MTU value is specified for the peer it will be honored.
> 
> 

OK, I see it. Does that mean that the patch needs to be updated or the proposed
behavior is incorrect and must not be in kernel?
