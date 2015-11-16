From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Routing loops & TTL tracking with tunnel devices
Date: Mon, 16 Nov 2015 21:55:19 +0100
Message-ID: <CAHmME9pNCqbcoqbOnx6p8poehAntyyy1jQhy=0_HjkJ8nvMQdw@mail.gmail.com>
References: <CAHmME9r_DbZWe4FsfebHSSf_iPctSe5S-w9bU3o8BN43raeURg@mail.gmail.com>
	<20151116203709.GA27178@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, therbert@google.com,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151116203709.GA27178@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sowmini,

Neat. Though, in my case, I'm not actually just prepending a header.
I'm doing some more substantial transformations of a packet. And this
needs to work with v4 too. So I'm not sure implementing a v6 spec will
help with things. I need to identify the right mechanism inside the
kernel to assist with this, like, say, a member in sk_buff.

Jason
