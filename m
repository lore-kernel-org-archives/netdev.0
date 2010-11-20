From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: remove an atomic bit operation
Date: Sun, 21 Nov 2010 07:38:05 +0800
Message-ID: <AANLkTimkr9DqkXMgRpRRu5oXvpSBm7Tf1R4svKhMCcgT@mail.gmail.com>
References: <1290239717-12664-1-git-send-email-xiaosuo@gmail.com>
 <4CE7F160.9050107@canonical.com> <1290271804.2756.78.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tim.gardner@canonical.com, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290271804.2756.78.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 21, 2010 at 12:50 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le samedi 20 novembre 2010 =E0 09:03 -0700, Tim Gardner a =E9crit :
>
>> NAK, set_bit() takes a bit number, not a mask. That is, assuming you=
 can
>> get away with a non-atomic operation on this field. I'll defer to
>> Patrick on that.
>>
>> I think you have to use IPS_CONFIRMED instead, e.g.,
>>
>> =A0 =A0 =A0 ct->status |=3D IPS_CONFIRMED;
>>
>
> Or
>
> =A0 =A0 =A0 =A0__set_bit(IPS_CONFIRMED_BIT, &ct->status);
>
>
> set_bit() is atomic, while __set_bit() is not
>

Oh, you are right. Thanks. My a previous patch accepted by Patrick has
the same problem.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
