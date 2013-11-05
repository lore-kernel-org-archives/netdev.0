From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net] vti: fix spd lookup: match plaintext pkt, not ipsec
 pkt
Date: Tue, 05 Nov 2013 15:31:57 +0100
Message-ID: <5279015D.5070408@6wind.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com> <5278ED2C.8070604@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34164 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932Ab3KEOcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 09:32:01 -0500
Received: by mail-wi0-f179.google.com with SMTP id hm4so2153673wib.12
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 06:32:00 -0800 (PST)
In-Reply-To: <5278ED2C.8070604@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

On 11/05/2013 02:05 PM, Sergei Shtylyov wrote:
>> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
>> index 6e87f85..a7e03c0 100644
>> --- a/net/ipv4/ip_vti.c
>> +++ b/net/ipv4/ip_vti.c
> [...]
>> @@ -133,7 +134,12 @@ static int vti_rcv(struct sk_buff *skb)
>>            * only match policies with this mark.
>>            */
>>           skb->mark = be32_to_cpu(tunnel->parms.o_key);
>> +        /* the packet is decrypted, but not yet decapsulated.
>> +         * Temporarily make network_header point to the inner header
>> +         * for policy check */
>
>    Multi-line comment style in the networking code is:
>
> /* bla
>  * bla
>  */
Sorry for that, I was not careful enough. I'll fix it right now.

Thanks and Best Regards,
Christophe
