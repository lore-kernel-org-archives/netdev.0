From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 6 Apr 2009 14:32:54 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904061430160.1189@fbirervta.pbzchgretzou.qr>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com> <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com> <49CE568A.9090104@cosmosbay.com> <20090328174835.0d0b63f8@nehalam> <49D1241B.6020504@cosmosbay.com>
 <20090330130532.1e433313@nehalam> <49D9F086.7090905@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49D9F086.7090905@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2009-04-06 14:07, Patrick McHardy wrote:
>>>
>>> if LOCKDEP is on, size of a spinlock is 64 bytes on x86_64.
>>> Adding a spinlock on each nf_conn would be too expensive. In this
>>> case, an array of spinlock is a good compromise, as done in
>>> IP route cache, tcp ehash, ...
>>
>> IMO having different locking based on lockdep and architecture is an
>> invitation
>> to future obscure problems. Perhaps some other locking method or shrinking
>> ct entry would be better.
>
> I agree. Do people enable lockdep on production machines?

They do not.[1]


[1] http://git.opensuse.org/?p=people/jblunck/kernel-source.git;a=blob;f=config/x86_64/default;hb=SL111_BRANCH
