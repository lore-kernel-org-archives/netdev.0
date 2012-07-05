From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH net-next 13/15] netfilter: nfdbus: Add D-bus message parsing
Date: Thu, 5 Jul 2012 19:54:21 +0200
Message-ID: <CAAwP0s3b0JjT9BvrGvynNJm5Pq0eQuHem352T3tDyxvVosbA+g@mail.gmail.com>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
 <1340988354-26981-14-git-send-email-vincent.sanders@collabora.co.uk>
 <20120629171108.GA6287@1984> <4FF1C1AF.9080104@collabora.co.uk> <20120704173047.GA8864@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120704173047.GA8864@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 4, 2012 at 7:30 PM, Pablo Neira Ayuso <pablo@netfilter.org>=
 wrote:
> On Mon, Jul 02, 2012 at 05:43:43PM +0200, Javier Martinez Canillas wr=
ote:
>> On 06/29/2012 07:11 PM, Pablo Neira Ayuso wrote:
>> > On Fri, Jun 29, 2012 at 05:45:52PM +0100, Vincent Sanders wrote:
>> >> From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
>> >>
>> >> The netfilter D-Bus module needs to parse D-bus messages sent by
>> >> applications to decide whether a peer can receive or not a D-Bus
>> >> message. Add D-bus message parsing logic to be able to analyze.
>> >
>> > Not talking about the entire patchset, only about the part I'm
>> > responsible for.
>> >
>> > I don't see why you think this belong to netfilter at all.
>> >
>> > This doesn't integrate into the existing filtering infrastructure,
>> > neither it extends it in any way.
>> >
>>
>> Hello Pablo,
>>
>> Thanks a lot for your feedback.
>>
>> This is the first of a set of patches that adds a netfilter module t=
o parse
>> D-Bus messages, the complete patch-set is:
>>
>> [PATCH 13/15] netfilter: nfdbus: Add D-bus message parsing
>> [PATCH 14/15] netfilter: nfdbus: Add D-bus match rule implementation
>> [PATCH 15/15] netfilter: add netfilter D-Bus module
>>
>> patches 13 and 14 just include D-Bus helper code to be used by the n=
etfilter
>> module (added on patch 15) and specially the dbus_filter netfilter h=
ook function.
>
> I see, the use of the netfilter hooks seems to be the only reason why
> you consider these chunks belong to netfilter.
>
>> For the next post version we will reorganize the patches so first th=
e D-Bus
>> netfilter module is added with an empty dbus_filter function and the=
n added the
>> D-Bus helper code.
>>
>> Also, we will move the nfdbus netfilter module to net/bus so is not =
inside the
>> netfilter core code.
>
> Yes, please, remove this stuff from my directory tree, I believe this
> filtering infrastructure has not much to do with Netfilter itself.
>
> It uses the connector to communicate kernel <-> userspace instead of
> nfnetlink and, as said, it does neither integrate into existing
> filtering kernel/userspace infrastructure nor integrates into it.
>
> So, please, if you plan to give another try to this patchset, move
> this to your net/bus directory as you propose and find a different
> (better) name for the filtering part (just to avoid confusion in the
> future).
>
> Thanks.

Hi Pablo,

Thanks a lot for your feedback and comments.

On a next patch-set post I'll move to net/bus and change the name as
you suggest.

Best regards,

--=20
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
Barcelona, Spain
