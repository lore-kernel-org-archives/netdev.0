From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to AF_UNIX
Date: Thu, 1 Mar 2012 18:02:14 +0200
Message-ID: <CABBYNZKN+7z4Sr9DBniokez6Jru02LxPgWdGNcVeYECse+AzEQ@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com>
	<1330606237.27405.5.camel@megeve>
	<1330606775.2465.56.camel@edumazet-laptop>
	<4F4F7FFB.6010608@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4F7FFB.6010608@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Javier,

On Thu, Mar 1, 2012 at 3:56 PM, Javier Martinez Canillas
<javier.martinez@collabora.co.uk> wrote:
>>
>> Anyway, if you think multicast sockets is the way to go, then you could
>> setup a virtual network just to be able to use AF_INET multicast.
>>
>> Thats probably doable without kernel patching.
>>
>
> We could use AF_INET multicast on a local machine but we need some
> ordering and control flow requirements that are not guaranteed on UDP
> multicast over IP. That's why we thought to add a new address family
> AF_MCAST.

I don't want to sound like a broken record, but Im afraid I have to,
what about Ancillary Messages, how you are going to support passing
fd? Actually the whole virtual network sounds like a bad idea, are we
going to give ips to each and every application connected to the bus,
actually it is necessary to have one virtual network for each bus.

Contrary to someones believes I don't think AF_INET is that fast (e.g.
http://scottmoonen.com/2008/04/05/a-performance-comparison-of-af_unix-with-loopback-on-linux/)


-- 
Luiz Augusto von Dentz
