From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2/2] [SKBUFF] introduce tr_hdr(skb)
Date: Wed, 06 Oct 2004 16:06:54 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4164424E.6000504@conectiva.com.br>
References: <41643C40.8070605@conectiva.com.br> <20041006185835.GB19714@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041006185835.GB19714@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Thomas Graf wrote:
> * Arnaldo Carvalho de Melo <41643C40.8070605@conectiva.com.br> 2004-10-06 15:41
> 
>>-		trh = (struct trh_hdr *)skb_push(skb, sizeof(*trh));
>>+		skb->mac.raw = skb_push(skb, sizeof(*trh));
>>+		trh = tr_hdr(skb);
>> 		trh->ac = AC;
>> 		trh->fc = LLC_FRAME;
>> 		if (sa)
>>@@ -51,7 +52,6 @@
>> 			memcpy(trh->daddr, da, dev->addr_len);
>> 			tr_source_route(skb, trh, dev);
>> 		}
>>-		skb->mac.raw = skb->data;
> 
> 
> Are you sure the bevhaviour is the same? There is an skb_pull
> in tr_source_route so skb->data gets modified. 
> 
> 


Thanks for reviewing, checking...
