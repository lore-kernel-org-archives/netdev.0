From: rick jones <rick.jones2@hp.com>
Subject: Re: Intel and TOE in the news
Date: Sun, 20 Feb 2005 11:45:02 -0800
Message-ID: <91f1bcca156f343c17918ce67ef23666@hp.com>
References: <4216B62D.6000502@pobox.com> <20050219041007.GA17896@xi.wantstofly.org> <20050219114624.373af63f.davem@davemloft.net> <m1psywb8i4.fsf@muc.de>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
In-Reply-To: <m1psywb8i4.fsf@muc.de>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> <speculating freely>
>
> It would be nice if the NIC could asynchronously trigger prefetches in
> the CPU. Currently a lot of the packet processing cost goes
> to waiting for read cache misses.
>
> E.g.
>
> - NIC receives packet.
> - Tells target CPU to prefetch RX descriptor and headers.
> - CPU later looks at them and doesn't have to wait a for a cache miss.
>
> Drawback is that you would need to tell the NIC in advance
> on which CPU you want to process the packet, but with Linux
> IRQ affinity that's easy to figure out.

With all the interrupt avoidance that is going-on these days, would 
prefetching in the driver be sufficient?  Presumably the driver is 
going to be processing multiple packets at a time on an interrupt/etc 
so having it issue prefetches in SW would seem to help with all but the 
very first packet.

rick jones
Wisdom teeth are impacted, people are affected by the effects of events
