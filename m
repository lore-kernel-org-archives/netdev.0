From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Routing loops & TTL tracking with tunnel devices
Date: Tue, 17 Nov 2015 03:41:35 +0100
Message-ID: <CAHmME9oTU7HwP5=qo=aFWe0YXv5EPGoREpF2k-QY7qTmkDeXEA@mail.gmail.com>
References: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
	<20151116203709.GA27178@oracle.com>
	<CAHmME9pNCqbcoqbOnx6p8poehAntyyy1jQhy=0_HjkJ8nvMQdw@mail.gmail.com>
	<1447712932.22599.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447712932.22599.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Mon, Nov 16, 2015 at 11:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> There is very little chance we'll accept a new member in sk_buff, unless
> proven needed.

I actually have no intention of doing this! I'm wondering if there
already is a member in sk_buff that moonlights as my desired ttl
counter, or if there's another mechanism for avoiding routing loops. I
want to work with what's already there, rather than meddling with the
innards of important and memory sensitive structures such as sk_buff.
