From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 09:17:25 -0700
Message-ID: <1375892245.4004.31.camel@edumazet-glaptop>
References: <20130807155443.a0355d0429f3e0b4ccbed261@canb.auug.org.au>
	 <CA+icZUW+uxCsvPYcY2RRvMxRVzaBLuH9u8M4ziQNWXv=nk4b2w@mail.gmail.com>
	 <20130807155918.GA16263@orbit.nwl.cc>
	 <1375891974.8154.1.camel@jlt4.sipsolutions.net>
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
In-Reply-To: <1375891974.8154.1.camel@jlt4.sipsolutions.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 18:12 +0200, Johannes Berg wrote:
> On Wed, 2013-08-07 at 17:59 +0200, Phil Sutter wrote:
> 
> > The idea behind this patch is that users setting the protocol to
> > something else probably do know better and so should be left alone.
> 
> Regardless of that, I think that still the skb pointers would be changed
> by this patch which would confuse the receiver of the SKB (device
> driver), no? Has anyone verified that theory? :)

Maybe receivers made wrong assumptions about some headers being set or
not set ?

A patch can uncover prior bugs.

commit 76fe45812a3b134c3917 is an example of a fix we had to do because
of another fix ;)
