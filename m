From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] netdevice ops
Date: Fri, 18 May 2007 00:54:13 -0400
Message-ID: <464D3175.8050007@pobox.com>
References: <20070517210737.17d88401@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45125 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755125AbXEREyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 00:54:22 -0400
In-Reply-To: <20070517210737.17d88401@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I want to take all the function pointers of 'struct net_device' and
> move them to 'struct net_device_ops'. This will save memory for the
> case of lots of devices, as well as reduce initialization code.

It will also add an additional deref to every operation, right?

	Jeff



