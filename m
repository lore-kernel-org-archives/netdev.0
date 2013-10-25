From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 5/5] 6lowpan: remove unecessary break
Date: Fri, 25 Oct 2013 17:05:54 +0400
Message-ID: <526A6CB2.1040007@cogentembedded.com>
References: <1382647904-11311-1-git-send-email-alex.aring@gmail.com> <1382647904-11311-6-git-send-email-alex.aring@gmail.com> <EFDF4460-F8D0-4721-82F1-ABC3D5F75FDA@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"werner@almesberger.net" <werner@almesberger.net>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34501 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab3JYNFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 09:05:53 -0400
Received: by mail-lb0-f179.google.com with SMTP id w6so723868lbh.10
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 06:05:52 -0700 (PDT)
In-Reply-To: <EFDF4460-F8D0-4721-82F1-ABC3D5F75FDA@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-10-2013 7:28, Alexander Smirnov wrote:

>> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
>> Reviewed-by: Werner Almesberger <werner@almesberger.net>
>> ---
>> net/ieee802154/6lowpan.c | 1 -
>> 1 file changed, 1 deletion(-)

>> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>> index e15b101..09350f1 100644
>> --- a/net/ieee802154/6lowpan.c
>> +++ b/net/ieee802154/6lowpan.c
>> @@ -440,7 +440,6 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
>>         default:
>>             pr_debug("ERROR: unknown UDP format\n");
>>             goto err;
>> -            break;
>>         }

> It's not an unnecessary, it's let say a "good coding practice" to have a break for every case including default.

    Even after *goto*? :-)

WBR, Sergei
