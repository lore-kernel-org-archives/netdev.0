From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Tue, 23 Jul 2013 19:32:08 -0700
Message-ID: <CANEJEGv9G0SSUQOPqbqb_Fpcth7Qz2nkT_zOUQG=U2FH=g1_XA@mail.gmail.com>
References: <1374518841.4990.26.camel@edumazet-glaptop>
	<1374522471.1635.48.camel@bwh-desktop.uk.level5networks.com>
	<1374559827.4990.143.camel@edumazet-glaptop>
	<20130723.164656.1794159338719943519.davem@davemloft.net>
	<CANEJEGtLavwdPdq_Qojz_x-DQ3KXfZp0vPYr6imKtNxN0Hf_2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANEJEGtLavwdPdq_Qojz_x-DQ3KXfZp0vPYr6imKtNxN0Hf_2Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 23, 2013 at 7:29 PM, Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Jul 23, 2013 at 4:46 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> ...
>> A quick scan shows that smsc75xx, smsc95xx, and ax88179_178a all have
>> this problem.
>>
>> Instead of the patch starting this thread, I'd like to see one that
>> hits all three drivers and removes all SG and TSO features bits from
>> both the ->features _and_ ->hw_features settings.
>
> Since you are asking to remove TSO, do you also want skb_linearize()
> calls in ax88179_178a.c and smsc75xx.c removed as well?

Nevermind...Eric already removed skb_linearize calls in his patch.

cheers,
grant

>
> Not part of the original patch - but based on this thread, Eric seems
> to think calling skb_linearize isn't necessary or helpful either.
>
> cheers,
> grant
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
