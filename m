From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [Devel] Re: [PATCH] Virtual ethernet tunnel
Date: Thu, 07 Jun 2007 12:14:29 +0400
Message-ID: <4667BE65.2060307@sw.ru>
References: <4666CEAA.8010903@openvz.org> <20070606.124758.85411179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, kaber@trash.net, dev@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:10221 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbXFGIOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 04:14:12 -0400
In-Reply-To: <20070606.124758.85411179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pavel Emelianov <xemul@openvz.org>
> Date: Wed, 06 Jun 2007 19:11:38 +0400
> 
> 
>>Veth stands for Virtual ETHernet. It is a simple tunnel driver
>>that works at the link layer and looks like a pair of ethernet
>>devices interconnected with each other.
> 
> 
> I would suggest choosing a different name.
> 
> 'veth' is also the name of the virtualized ethernet device
> found on IBM machines, driven by driver/net/ibmveth.[ch]

AFAICS, ibmveth.c registers ethX devices, while this driver registers
vethX by default, so there is no much conflict IMHO.

But if you still don't like it, I would suggest 'ethtun' and later
we will come with iptun for IP tunneling. Is it ok for you?

Thanks,
Kirill

