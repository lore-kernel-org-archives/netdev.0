From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH] net: kdoc struct net_device flags and priv_flags
Date: Tue, 25 Feb 2014 15:08:08 -0800
Message-ID: <CAB=NE6VQUpjXkDYjjc1bLeC+3X9cPpP83Kg6O3P=Yju=JaYAZw@mail.gmail.com>
References: <1393287245-4549-1-git-send-email-mcgrof@do-not-panic.com>
 <1393294265.6823.154.camel@deadeye.wl.decadent.org.uk> <20140224.235343.1936318499491821387.davem@davemloft.net>
 <2446186.I4KkJ8Hjdb@lenovo> <CAB=NE6WAmHqAYsh6rwyHdvZy3J6ck-uD_Kavk3qqy02vML359g@mail.gmail.com>
 <CAGVrzcaaViC10TvnSVBJsKRF3pSOvbP7Z+Kh4Qcu0RS_RY5GBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcaaViC10TvnSVBJsKRF3pSOvbP7Z+Kh4Qcu0RS_RY5GBA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 25, 2014 at 2:39 PM, Florian Fainelli <f.fainelli@gmail.com=
> wrote:
> 2014-02-25 14:19 GMT-08:00 Luis R. Rodriguez <mcgrof@do-not-panic.com=
>:
>> On Mon, Feb 24, 2014 at 9:37 PM, Florian Fainelli <f.fainelli@gmail.=
com> wrote:
>>> Le lundi 24 f=C3=A9vrier 2014, 23:53:43 David Miller a =C3=A9crit :
>>>> They are visible to userspace via sysfs.
>>>
>>> In /sys/class/net/*/flags, although we are lacking quite a lot of d=
ocumentation
>>> for the exported attributes there.
>>
>> I only see dev->flags there, I don't see any toggle capability for
>> priv_flags. Let me know if you find anywhere that userspace lets a
>> user toggle private flags, I just don't see it.
>
> You are right, those are dev->flags, not priv_flags, sorry about that=
=2E

No worries, if I don't hear back from anyone about how this is exposed
to userspace I'll toss a 2nd patch to the series that moves the
priv_flags out of UAPI as Ben suggested as a second step. Ben's point
about it being an unstable interface if userspace would rely on them
is also pretty important, so not sure why we'd let anyone on userspace
rely on them. I'll obviously test compile this before submitting
though.

  Luis
