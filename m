From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Routing loops & TTL tracking with tunnel devices
Date: Mon, 16 Nov 2015 14:28:52 -0800
Message-ID: <1447712932.22599.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
	 <20151116203709.GA27178@oracle.com>
	 <CAHmME9pNCqbcoqbOnx6p8poehAntyyy1jQhy=0_HjkJ8nvMQdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Jiri Benc <jbenc@redhat.com>, therbert@google.com,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pNCqbcoqbOnx6p8poehAntyyy1jQhy=0_HjkJ8nvMQdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-16 at 21:55 +0100, Jason A. Donenfeld wrote:
> Hi Sowmini,
> 
> Neat. Though, in my case, I'm not actually just prepending a header.
> I'm doing some more substantial transformations of a packet. And this
> needs to work with v4 too. So I'm not sure implementing a v6 spec will
> help with things. I need to identify the right mechanism inside the
> kernel to assist with this, like, say, a member in sk_buff.

There is very little chance we'll accept a new member in sk_buff, unless
proven needed.

Yes, it is very tempting and dozen of programmers already tried.

You'll have to demonstrate full understanding of the stack and why other
solutions do not work.
