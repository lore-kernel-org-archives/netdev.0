From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: A generic kernel compatibilty code
Date: Fri, 20 Nov 2009 18:12:27 -0800
Message-ID: <43e72e890911201812r6551422bk276bbcaf3179d5cc@mail.gmail.com>
References: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
	<43e72e890911201251t6210ee19n177eaf003a4fffc@mail.gmail.com>
	<43e72e890911201253obc466c8k2102e04457c48c92@mail.gmail.com>
	<20091120211837.GA22815@tuxdriver.com> <43e72e890911201338w4c403d51q651afc3638d1739c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <43e72e890911201338w4c403d51q651afc3638d1739c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2009 at 1:38 PM, Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> w=
rote:
> On Fri, Nov 20, 2009 at 1:18 PM, John W. Linville
> <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>> On Fri, Nov 20, 2009 at 12:53:51PM -0800, Luis R. Rodriguez wrote:
>>> On Fri, Nov 20, 2009 at 12:51 PM, Luis R. Rodriguez <mcgrof@gmail.c=
om> wrote:
>>> > On Fri, Nov 20, 2009 at 12:45 PM, Luis R. Rodriguez <mcgrof@gmail=
=2Ecom> wrote:
>>> >> Everyone and their mother reinvents the wheel when it comes to
>>> >> backporting kernel modules. It a painful job and it seems to me =
an
>>> >> alternative is possible. If we can write generic compatibilty co=
de for
>>> >> a new routine introduced on the next kernel how about just mergi=
ng it
>>> >> to the kernel under some generic compat module. This would be
>>> >> completey ignored by everyone using the stable kernel but can be
>>> >> copied by anyone doing backport work.
>>> >>
>>> >> So I'm thinking something as simple as a generic compat/comat.ko=
 with
>>> >> compat-2.6.32.[ch] files.
>>> >
>>> > FWIW, I meant a compat-2.6.32.[ch] and compat-2.6.31.[ch] and so =
on.
>>> > All these would link to the compat.ko
>>>
>>> I supose this could juse be a separate tree with some generic
>>> compat.ko module. That might work better.
>>
>> This is what I would suggest for pursuing this idea. =C2=A0Perhaps y=
ou
>> could split-off from compat-wireless, then make that tree depend on
>> the new tree (compat-core?)...
>
> OK thanks, will try that for the next kernel.

I've packaged a compat.ko here:

git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/compat.git

This should be up as soon as the kernel.org synchs. The missing piece
would just be to define a common place to put the headers for
distributions who want to use external modules which want to use this
thing.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
