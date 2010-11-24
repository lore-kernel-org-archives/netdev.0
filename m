From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] af_unix: limit unix_tot_inflight
Date: Wed, 24 Nov 2010 15:44:53 +0100
Message-ID: <877hg2g4re.fsf@basil.nowhere.org>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
	<1290553918.2866.80.camel@edumazet-laptop>
	<1290590335.3464.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290590335.3464.24.camel@edumazet-laptop> (Eric Dumazet's
	message of "Wed, 24 Nov 2010 10:18:55 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> diff --git a/net/unix/garbage.c b/net/unix/garbage.c
> index c8df6fd..40df93d 100644
> --- a/net/unix/garbage.c
> +++ b/net/unix/garbage.c
> @@ -259,9 +259,16 @@ static void inc_inflight_move_tail(struct unix_sock *u)
>  }
>  
>  static bool gc_in_progress = false;
> +#define UNIX_INFLIGHT_TRIGGER_GC 16000

It would be better to define this as a percentage of
lowmem.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
