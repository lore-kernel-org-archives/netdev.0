From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: Re: [PATCH v5 1/2] net: moxa: clear TX descriptor length bits
Date: Mon, 25 Aug 2014 16:23:35 +0200
Message-ID: <CACmBeS30_NUot6=FK3xNVDxfN+CPXNfNhEBcO4OPAOQ3Q9zQzw@mail.gmail.com>
References: <1408459784-9385-1-git-send-email-jonas.jensen@gmail.com>
	<1408544322-32023-1-git-send-email-jonas.jensen@gmail.com>
	<1408554610.5604.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>, davem <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408554610.5604.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for giving feedback.

On 20 August 2014 19:10, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Wouldnt it be faster to not use readl() at all here ?

On 22 August 2014 06:39, David Miller <davem@davemloft.net> wrote:
> Like others I wonder why the existing descriptor value is being read
> at all.

It makes sense and I have verified, transfers continue to work
clearing the whole thing, see update in v6.


Regards,

   Jonas
