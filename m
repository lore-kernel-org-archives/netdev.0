From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Wed, 07 Aug 2013 14:39:45 -0700
Message-ID: <1375911585.4004.55.camel@edumazet-glaptop>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	 <1375898766.4004.37.camel@edumazet-glaptop>
	 <20130807205959.GC21463@macbook.localnet>
	 <20130807210540.GE32257@order.stressinduktion.org>
	 <20130807212410.GA22932@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130807212410.GA22932@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-07 at 23:24 +0200, Patrick McHardy wrote:

> I see. Well, that seems to be a general problem with SYN cookies, I guess
> in that case the encoding Linux uses should be changed. I'll have a closer
> look at the changes proposed in that thread tommorrow.

I did a quick check on a host, and it turns out that 111664 SYN had TS
option (total of 146123 SYN messages received)

So maybe its not a big issue. We probably need a poll ;)


