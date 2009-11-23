From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH] net/ipv[46]/netfilter: Move && and || to
 end of previous line
Date: Mon, 23 Nov 2009 23:20:15 +0100
Message-ID: <4B0B0A9F.30500@trash.net>
References: <4B06AC2C.3070102@gmail.com>	 <20091120.092651.254794724.davem@davemloft.net> <4B08D967.80003@gmail.com>	 <20091122.163112.80105623.davem@davemloft.net> <1259005771.16503.90.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52608 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213AbZKWWUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:20:12 -0500
In-Reply-To: <1259005771.16503.90.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Sun, 2009-11-22 at 16:31 -0800, David Miller wrote:
>   
>> It should be of the form:
>> 	if (x &&
>> 	    y)
>>
>> or:
>> 	if (x && y)
>>
>> Fix patches, rather than complaints, for existing cases where things
>> do not follow this pattern are certainly welcome.
>>     
>
> Compile tested only.
>   

Applied, thanks for cleaning this up.

