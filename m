From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: A generic kernel compatibilty code
Date: Fri, 20 Nov 2009 12:53:51 -0800
Message-ID: <43e72e890911201253obc466c8k2102e04457c48c92@mail.gmail.com>
References: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
	<43e72e890911201251t6210ee19n177eaf003a4fffc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890911201251t6210ee19n177eaf003a4fffc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2009 at 12:51 PM, Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, Nov 20, 2009 at 12:45 PM, Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Everyone and their mother reinvents the wheel when it comes to
>> backporting kernel modules. It a painful job and it seems to me an
>> alternative is possible. If we can write generic compatibilty code for
>> a new routine introduced on the next kernel how about just merging it
>> to the kernel under some generic compat module. This would be
>> completey ignored by everyone using the stable kernel but can be
>> copied by anyone doing backport work.
>>
>> So I'm thinking something as simple as a generic compat/comat.ko with
>> compat-2.6.32.[ch] files.
>
> FWIW, I meant a compat-2.6.32.[ch] and compat-2.6.31.[ch] and so on.
> All these would link to the compat.ko

I supose this could juse be a separate tree with some generic
compat.ko module. That might work better.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
