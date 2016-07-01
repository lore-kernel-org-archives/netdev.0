From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [RFC] WireGuard: next generation secure network tunnel
Date: Fri, 1 Jul 2016 13:42:58 +0200
Message-ID: <CAFLxGvzk5NywJou_g9_z6JQUrvcTNsAUPXt4R6AdS9nmRqYwcw@mail.gmail.com>
References: <CAHmME9q-6ioctzcB8gLdYOsMFqHVGY8GUsVGFisKv=wGdVqi2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-crypto@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9q-6ioctzcB8gLdYOsMFqHVGY8GUsVGFisKv=wGdVqi2A@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 4:49 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> WireGuard acts as a virtual interface, doing layer 3 IP tunneling,
> addable with "ip link add dev wg0 type wireguard". You can set the
> interface's local IP and routes using the usual ip-address and

So every logical tunnel will allocate a new net device?
Doesn't this scale badly? I have ipsec alike setups
with many, many road warriors in mind.

-- 
Thanks,
//richard
