From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 09:40:09 -0700
Message-ID: <1375893609.4004.33.camel@edumazet-glaptop>
References: <20130807155443.a0355d0429f3e0b4ccbed261@canb.auug.org.au>
	 <CA+icZUW+uxCsvPYcY2RRvMxRVzaBLuH9u8M4ziQNWXv=nk4b2w@mail.gmail.com>
	 <20130807155918.GA16263@orbit.nwl.cc>
	 <1375891974.8154.1.camel@jlt4.sipsolutions.net>
	 <1375892245.4004.31.camel@edumazet-glaptop>
	 (sfid-20130807_181729_176093_C3201A13) <1375892522.8154.3.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Sedat Dilek <sedat.dilek@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	wireless <linux-wireless@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1375892522.8154.3.camel@jlt4.sipsolutions.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 18:22 +0200, Johannes Berg wrote:

> Maybe. I haven't tested it, but I'm thinking that skb->data doesn't
> point to the start of the data frame in this case, since we now call
> eth_type_trans() which pulls the ethernet header. So if the device just
> transmits skb->len starting from skb->data, it'll be wrong, no? That
> seems a basic assumption though.

Yes, it seems calling eth_type_trans() is not right here, and even could
crash.

Sorry, for being vague, I am a bit busy this morning.
