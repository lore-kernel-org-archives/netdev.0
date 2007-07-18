From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 15:54:56 +0200
Message-ID: <469E1BB0.2040104@trash.net>
References: <200707181527.38895.florian.fainelli@telecomint.eu> <469E16C5.4000102@trash.net> <200707181544.11890.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpurdie@rpsys.net
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39347 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905AbXGRN6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 09:58:07 -0400
In-Reply-To: <200707181544.11890.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
>> Besides missing a declaration and not linking without the network
>> LED config option, its pretty ridiculous to call this for every
>> packet just to make a led blink.
>>     
>
> Could you suggest me a better way to do so ? The code was highly inspired from 
> what is done with the IDE trigger. The declaration is done in linux/leds.h, 
> which is included in dev.c for that purpose.
>   

Maybe just increment a variable and periodically check it or something
like that.


