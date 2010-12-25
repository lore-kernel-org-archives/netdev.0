From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] Ceph: Fix a use-after-free bug in ceph_destroy_client().
Date: Sat, 25 Dec 2010 22:40:11 +0100
Message-ID: <AANLkTincx8rSM+72czJ+tTrG=D=aOJLBb9nd9Jt_RsD2@mail.gmail.com>
References: <alpine.LNX.2.00.1012251914370.10759@swampdragon.chaosbits.net>
	<AANLkTik+yrpY8T69w_RQ84ZbRqwkjvFhvxHLBvU14N3f@mail.gmail.com>
	<alpine.LNX.2.00.1012252223380.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ceph-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Sage Weil <sage@newdream.net>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012252223380.10759@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 25, 2010 at 10:24 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> On Sat, 25 Dec 2010, richard -rw- weinberger wrote:
>
>> On Sat, Dec 25, 2010 at 7:17 PM, Jesper Juhl <jj@chaosbits.net> wrot=
e:
>> > Hello,
>> >
>> > In net/ceph/ceph_common.c::ceph_destroy_client() the pointer 'clie=
nt' is
>> > freed by kfree() and subsequently used in a call to dout() - use a=
fter
>> > free bug.
>>
>> Not really. %p reads only the address of "client".
>> kfree() does not alter this address.
>>
>
> Ok, I see your point and you are correct. But still, the patch does n=
ot
> change behaviour and it makes it absolutely clear that there's no
> use-after-free bug, so it might still have merit... or?

Your patch does not fix a bug.
I would say it's a style fix.

> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0http://www.chao=
sbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
>
>



--=20
Thanks,
//richard
