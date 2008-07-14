From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bridge] bridging with gre tunnel
Date: Mon, 14 Jul 2008 14:15:14 +0200
Message-ID: <487B4352.6040408@trash.net>
References: <E1KIMV2-0007Na-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Philip Craig <philipc@snapgear.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, timo.teras@iki.fi
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42694 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbYGNMQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 08:16:46 -0400
In-Reply-To: <E1KIMV2-0007Na-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Philip Craig <philipc@snapgear.com> wrote:
>> Actually, this change doesn't really belong in GRE either, because
>> that forces you to choose between ethernet encapsulation and not.
>> It could be a new device that sits on top of GRE and simply does
>> ethernet encapsulation then passes it to the raw GRE device.
>> That's a lot of infrastructure for something so simple though,
>> and I don't think people will want to use both devices at once.
> 
> What's the problem with using Ethernet encapsulation on such a
> GRE device? If you're referring to the fact that user-space uses
> the encapsulation type to determine whether a device is a tunnel,
> then we should fix those tools instead.
> 
> Rather than trying to resuscitate the ioctl interface, please
> create a new extensible netlink interface and make ip(8) use it
> where available.


Or use rtnl_link, which was created for this purpose :)
