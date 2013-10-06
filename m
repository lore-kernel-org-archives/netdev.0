From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: af802154: Fix wrong structure declaration
Date: Sun, 06 Oct 2013 16:18:17 -0700
Message-ID: <5251EFB9.7040206@roeck-us.net>
References: <1381095841-15031-1-git-send-email-linux@roeck-us.net> <1381098047.2081.169.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:51615 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905Ab3JFXSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 19:18:23 -0400
In-Reply-To: <1381098047.2081.169.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2013 03:20 PM, Joe Perches wrote:
> On Sun, 2013-10-06 at 14:44 -0700, Guenter Roeck wrote:
>> net_devce doesn't exist.
> []
>> diff --git a/net/ieee802154/af802154.h b/net/ieee802154/af802154.h
> []
>> @@ -25,7 +25,7 @@
>>   #define AF802154_H
>>
>>   struct sk_buff;
>> -struct net_devce;
>> +struct net_device;
>
> That argues more for deletion than correction.
>

I thought the idea was to ensure that every structure is declared.
In this case it appears that the structure happens to be declared
in other include files, so we are lucky. On the other side, if so,
"struct proto", "struct net" and "struct ieee802154_addr" should
probably be declared as well ...

Ultimately, I don't really care one way or another. I just happened
to stumble over it. Fine with me to remove it. Maybe the maintainers
should decide what if anything to do.

Guenter
