From: MuraliRaja Muniraju <muralira@google.com>
Subject: Re: [PATCH v3] net-netlink: Add a new attribute to expose TOS values
 via netlink
Date: Wed, 12 Oct 2011 12:00:23 -0700
Message-ID: <CAP3iWTSkPinSDbi761EsUQ_ZX54e=yGioC7=c7qHRd+17-_xqw@mail.gmail.com>
References: <20111010145206.6f7e9ee2@nehalam.linuxnetplumber.net>
	<1318382887-31824-1-git-send-email-muralira@google.com>
	<1318387734.3686.2.camel@edumazet-laptop>
	<CAP3iWTQXHwzw-qUYVfT--uNv4pNZnu0ROJnF7B1VLeZBbrfdqw@mail.gmail.com>
	<1318393869.3686.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318393869.3686.26.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,
     I am planning to not add code for the TIME_WAIT case as the tos
values are zero as they are not saved. Please let me if this is OK.
Thanks,
Murali

On Tue, Oct 11, 2011 at 9:31 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 11 octobre 2011 =E0 21:16 -0700, MuraliRaja Muniraju a =E9cr=
it :
>> Eric,
>> =A0 =A0 =A0I think it would be useful to expose the values this way.
>> =A0 =A0 =A0I shall make the changes to add TCLASS for ipv6 in the de=
scription.
>>
>> =A0 =A0 =A0Regarding the TIME_WAIT state, I think it would be better=
 of not
>> exposing the values because there would hardly be anything to transm=
it
>> during this time.
>>
>
> My remark had nothing to do with your patch actually :
>
> We dont store TOS/TCLASS on TIME_WAIT sockets, so you cannot report
> value in inet_diag.
>
> But we do send packets on behalf of TIME_WAIT sockets ;)
>
> Think about ACK messages. They probably are sent with a 0 TOS/TCLASS
> field... I am not sure its a problem or not.
>
>
>
>



--=20
Thanks,
Murali
