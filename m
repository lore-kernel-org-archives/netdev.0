From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 14:56:26 -0700
Message-ID: <1434059786.27504.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	 <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5579FABE.4050505@fb.com>
	 <1434057733.27504.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150611214525.GA406740@devbig257.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Mason <clm@fb.com>, netdev@vger.kernel.org, davem@davemloft.net,
	Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes
	 <rientjes@google.com>, linux-mm@kvack.org
To: Shaohua Li <shli@fb.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150611214525.GA406740@devbig257.prn2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-06-11 at 14:45 -0700, Shaohua Li wrote:

> This is exactly what the patch try to do. Atomic 32k allocation will
> fail with memory pressure, kswapd is waken up to do compaction and we
> fallback to 4k.

Read your changelog, then read what you just wrote.

Your changelog  said :

'compaction will not be triggered and we will fallback to order-0
immediately.'

Now you tell me that compaction is started.

What is the truth ?

Please make sure changelog is precise, this would avoid many mails.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
