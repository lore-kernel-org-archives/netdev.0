From: Andi Kleen <andi@firstfloor.org>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Sun, 30 Oct 2011 10:59:18 +0100
Message-ID: <20111030095918.GA19676@one.firstfloor.org>
References: <1319772566.6759.27.camel@deadeye> <1319777025.23112.67.camel@edumazet-laptop> <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com> <1319803781.23112.113.camel@edumazet-laptop> <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com> <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com> <1319813252.23112.122.camel@edumazet-laptop> <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com> <CA+55aFz=sxRjw6u-ww0P=9hhvWaZP=+QJZ68W+B9WtvQqj9Ogg@mail.gmail.com> <1319964754.13597.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1319964754.13597.26.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +#define ACCESS_AT_MOST_ONCE(x)			\
> +	({	unsigned long __y;		\

why not typeof here?

> +		asm("":"=r" (__y):"0" (x));	\
> +		(__force __typeof__(x)) __y;	\
> +	})
> +

-Andi
