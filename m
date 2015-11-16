From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Routing loops & TTL tracking with tunnel devices
Date: Mon, 16 Nov 2015 15:59:50 -0500
Message-ID: <20151116205950.GB27178@oracle.com>
References: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
 <20151116203709.GA27178@oracle.com>
 <CAHmME9pNCqbcoqbOnx6p8poehAntyyy1jQhy=0_HjkJ8nvMQdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, therbert@google.com,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHmME9pNCqbcoqbOnx6p8poehAntyyy1jQhy=0_HjkJ8nvMQdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Neat. Though, in my case, I'm not actually just prepending a header.
> I'm doing some more substantial transformations of a packet. And this
> needs to work with v4 too. So I'm not sure implementing a v6 spec will

Understood, that spec was just referenced to indicate that there
are more issues (mtu reduction etc) with nested encapsulation,
and this is actually applicable even without the recursion issue
(i.e even if you dont have a tunnelling loop, and even if it
is not ipv6, there are some non-trivial problems here. Luckily,
nested encaps is somewhat uncommon).

--Sowmini
